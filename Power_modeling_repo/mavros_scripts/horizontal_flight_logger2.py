#!/usr/bin/env python3
import rospy, csv, time, math
from mavros_msgs.msg import PositionTarget
from mavros_msgs.srv import CommandBool, SetMode, CommandTOL
from geometry_msgs.msg import TwistStamped
from sensor_msgs.msg import BatteryState
from std_msgs.msg import Header
from datetime import datetime

velocity = 0.0
voltage = 0.0
current = 0.0

def vel_callback(msg):
    global velocity
    vx, vy, vz = msg.twist.linear.x, msg.twist.linear.y, msg.twist.linear.z
    velocity = math.sqrt(vx**2 + vy**2 + vz**2)

def battery_callback(msg):
    global voltage, current
    voltage, current = msg.voltage, abs(msg.current)

def set_flight_mode(mode):
    rospy.wait_for_service('/mavros/set_mode')
    return set_mode_client(custom_mode=mode).mode_sent

def arm_drone():
    rospy.wait_for_service('/mavros/cmd/arming')
    return arming_client(True).success

def takeoff_drone(altitude):
    rospy.wait_for_service('/mavros/cmd/takeoff')
    return takeoff_client(altitude=altitude).success

def move_with_velocity(vx, vy, vz, yaw=0.0):
    sp = PositionTarget()
    sp.header = Header()
    sp.header.stamp = rospy.Time.now()
    sp.coordinate_frame = PositionTarget.FRAME_LOCAL_NED
    sp.type_mask = PositionTarget.IGNORE_PX | PositionTarget.IGNORE_PY | PositionTarget.IGNORE_PZ | \
                   PositionTarget.IGNORE_AFX | PositionTarget.IGNORE_AFY | PositionTarget.IGNORE_AFZ | \
                   PositionTarget.IGNORE_YAW_RATE
    sp.velocity.x = vx
    sp.velocity.y = vy
    sp.velocity.z = vz
    sp.yaw = yaw
    local_position_pub.publish(sp)

rospy.init_node('horizontal_flight_logger2')

local_position_pub = rospy.Publisher('/mavros/setpoint_raw/local', PositionTarget, queue_size=10)
arming_client = rospy.ServiceProxy('/mavros/cmd/arming', CommandBool)
set_mode_client = rospy.ServiceProxy('/mavros/set_mode', SetMode)
takeoff_client = rospy.ServiceProxy('/mavros/cmd/takeoff', CommandTOL)

rospy.Subscriber('/mavros/local_position/velocity_local', TwistStamped, vel_callback)
rospy.Subscriber('/mavros/battery', BatteryState, battery_callback)

if __name__ == '__main__':
    try:
        print("🚀 Horizontal flight experiment (Part 2: 8–15 m/s)")
        set_flight_mode('GUIDED')
        arm_drone()
        takeoff_drone(20)
        rospy.sleep(15)

        filename1 = '/home/neha/ardupilot/ArduCopter/horizontal_flight_data_part2.csv'
        with open(filename1, 'w') as f1:
            writer = csv.writer(f1)
            writer.writerow(["Timestamp","Velocity(m/s)","Voltage(V)","Current(A)","Power(W)","TargetSpeed(m/s)"])
            for spd in range(7, 16, 1):
                print(f"➡️ Speed step {spd} m/s")
                start_time = time.time()
                while time.time() - start_time < 20:
                    move_with_velocity(spd, 0, 0)
                    ts = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
                    power = voltage * current
                    writer.writerow([ts, round(velocity,3), round(voltage,3), round(current,3), round(power,3), spd])
                    rospy.sleep(0.1)
                print(f"✅ Finished {spd} m/s")

        print("🎯 Part 2 completed ")

        # === Part 2: Run separately after restarting SITL ===
        # Repeat same script but change range:
        # for spd in range(7, 16, 1):
        #     ... log to horizontal_flight_data_part2.csv

    except rospy.ROSInterruptException:
        print("❌ Script interrupted.")

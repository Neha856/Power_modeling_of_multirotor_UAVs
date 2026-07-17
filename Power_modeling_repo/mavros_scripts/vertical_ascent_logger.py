#!/usr/bin/env python3
import rospy, csv, time
from mavros_msgs.msg import PositionTarget
from mavros_msgs.srv import CommandBool, SetMode, CommandTOL
from geometry_msgs.msg import TwistStamped
from sensor_msgs.msg import BatteryState
from std_msgs.msg import Header
from datetime import datetime

# Global telemetry
vz = 0.0
voltage = 0.0
current = 0.0

# Velocity callback
def vel_callback(msg):
    global vz
    vz = msg.twist.linear.z

# Battery callback
def battery_callback(msg):
    global voltage, current
    voltage, current = msg.voltage, abs(msg.current)

# Services
def set_flight_mode(mode):
    rospy.wait_for_service('/mavros/set_mode')
    return set_mode_client(custom_mode=mode).mode_sent

def arm_drone():
    rospy.wait_for_service('/mavros/cmd/arming')
    return arming_client(True).success

def takeoff_drone(altitude):
    rospy.wait_for_service('/mavros/cmd/takeoff')
    return takeoff_client(altitude=altitude).success

# Command altitude target
def move_to_altitude(z, yaw=0.0):
    sp = PositionTarget()
    sp.header = Header()
    sp.header.stamp = rospy.Time.now()
    sp.coordinate_frame = PositionTarget.FRAME_LOCAL_NED
    sp.type_mask = PositionTarget.IGNORE_VX | PositionTarget.IGNORE_VY | PositionTarget.IGNORE_VZ | \
                   PositionTarget.IGNORE_AFX | PositionTarget.IGNORE_AFY | PositionTarget.IGNORE_AFZ | \
                   PositionTarget.IGNORE_YAW_RATE
    sp.position.x = 0.0
    sp.position.y = 0.0
    sp.position.z = z
    sp.yaw = yaw
    local_position_pub.publish(sp)

# Init node
rospy.init_node('vertical_ascent_logger')

# Publisher + services
local_position_pub = rospy.Publisher('/mavros/setpoint_raw/local', PositionTarget, queue_size=10)
arming_client = rospy.ServiceProxy('/mavros/cmd/arming', CommandBool)
set_mode_client = rospy.ServiceProxy('/mavros/set_mode', SetMode)
takeoff_client = rospy.ServiceProxy('/mavros/cmd/takeoff', CommandTOL)

# Subscribers
rospy.Subscriber('/mavros/local_position/velocity_body', TwistStamped, vel_callback)
rospy.Subscriber('/mavros/battery', BatteryState, battery_callback)

# Main
if __name__ == '__main__':
    try:
        print("🚀 Initializing vertical ascent experiment...")
        set_flight_mode('GUIDED')
        arm_drone()
        takeoff_drone(2)   # safe hover start
        rospy.sleep(5)

        filename = '/home/neha/ardupilot/ArduCopter/vertical_ascent_data1.csv'
        with open(filename, 'w') as f:
            writer = csv.writer(f)
            writer.writerow(["Timestamp", "Vz(m/s)", "Voltage(V)", "Current(A)", "Power(W)", "TargetVz(m/s)", "TargetAlt(m)"])

            # Sweep ascent speeds 0 → 5 m/s in 0.5 steps
            ascent_speeds = [i*0.5 for i in range(11)]
            current_alt = 2.0  # start altitude

            for spd in ascent_speeds:
                target_alt = current_alt + 10.0  # climb only 10 m per step
                print(f"  Ascending {10} m at {spd} m/s (from {current_alt} → {target_alt})")

                start_time = time.time()
                while time.time() - start_time < 12:  # ~12s per step
                    move_to_altitude(target_alt)
                    ts = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
                    power = voltage * current
                    writer.writerow([ts, round(vz,3), round(voltage,3), round(current,3), round(power,3), spd, target_alt])
                    rospy.sleep(0.1)  # 10 Hz logging

                current_alt = target_alt
                print(f"✅ Finished ascent step {spd} m/s → reached {target_alt} m")
                rospy.sleep(3)

        print(f"🎯 All ascent data logged successfully. CSV saved at: {filename}")

    except rospy.ROSInterruptException:
        print("❌ Script interrupted before completion.")


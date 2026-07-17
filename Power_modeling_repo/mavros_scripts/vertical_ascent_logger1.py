#!/usr/bin/env python3
import rospy, csv, time
from mavros_msgs.msg import PositionTarget
from mavros_msgs.srv import CommandBool, SetMode, CommandTOL
from geometry_msgs.msg import TwistStamped, PoseStamped
from sensor_msgs.msg import BatteryState
from std_msgs.msg import Header
from datetime import datetime

# Global telemetry
vz = 0.0
voltage = 0.0
current = 0.0
current_alt = 0.0

# Velocity callback
def vel_callback(msg):
    global vz
    vz = msg.twist.linear.z

# Battery callback
def battery_callback(msg):
    global voltage, current
    voltage, current = msg.voltage, abs(msg.current)

# Altitude callback
def alt_callback(msg):
    global current_alt
    current_alt = msg.pose.position.z

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

# Command vertical velocity
def move_with_velocity(vz_cmd, yaw=0.0):
    sp = PositionTarget()
    sp.header = Header()
    sp.header.stamp = rospy.Time.now()
    sp.coordinate_frame = PositionTarget.FRAME_LOCAL_NED
    sp.type_mask = PositionTarget.IGNORE_PX | PositionTarget.IGNORE_PY | PositionTarget.IGNORE_PZ | \
                   PositionTarget.IGNORE_AFX | PositionTarget.IGNORE_AFY | PositionTarget.IGNORE_AFZ | \
                   PositionTarget.IGNORE_YAW_RATE
    sp.velocity.x = 0.0
    sp.velocity.y = 0.0
    sp.velocity.z = vz_cmd
    sp.yaw = yaw
    local_position_pub.publish(sp)

# Init node
rospy.init_node('vertical_ascent_logger1')

# Publisher + services
local_position_pub = rospy.Publisher('/mavros/setpoint_raw/local', PositionTarget, queue_size=10)
arming_client = rospy.ServiceProxy('/mavros/cmd/arming', CommandBool)
set_mode_client = rospy.ServiceProxy('/mavros/set_mode', SetMode)
takeoff_client = rospy.ServiceProxy('/mavros/cmd/takeoff', CommandTOL)

# Subscribers
rospy.Subscriber('/mavros/local_position/velocity_body', TwistStamped, vel_callback)
rospy.Subscriber('/mavros/battery', BatteryState, battery_callback)
rospy.Subscriber('/mavros/local_position/pose', PoseStamped, alt_callback)

# Main
if __name__ == '__main__':
    try:
        print("🚀 Initializing vertical ascent experiment...")
        set_flight_mode('GUIDED')
        arm_drone()
        takeoff_drone(2)   # safe hover start
        rospy.sleep(5)

        filename = '/home/neha/ardupilot/ArduCopter/vertical_ascent_data_balanced2.csv'
        with open(filename, 'w') as f:
            writer = csv.writer(f)
            writer.writerow(["Timestamp", "Vz(m/s)", "Voltage(V)", "Current(A)", "Power(W)", "TargetVz(m/s)", "CurrentAlt(m)"])

            # Speeds 0.5 → 5.0 m/s in 0.5 steps
            ascent_speeds = [i*0.5 for i in range(1,11)]
            # Balanced altitude bands (≈100 m total)
            altitude_bands = [8,8,8,8,8,8,8,9,9,8]

            current_alt = 2.0  # start altitude

            for spd, band in zip(ascent_speeds, altitude_bands):
                target_alt = current_alt + band
                print(f"  Ascending {band} m at {spd} m/s (from {current_alt:.1f} → {target_alt:.1f})")

                while current_alt < target_alt and current_alt < 160.0:
                    move_with_velocity(spd)
                    ts = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
                    power = voltage * current
                    writer.writerow([ts, round(vz,3), round(voltage,3), round(current,3), round(power,3), spd, round(current_alt,2)])
                    rospy.sleep(0.1)  # 10 Hz logging

                current_alt = min(target_alt, 110.0)
                print(f"✅ Finished ascent step {spd} m/s → reached {current_alt:.1f} m")
                rospy.sleep(3)

        print(f"🎯 All balanced ascent data logged successfully. CSV saved at: {filename}")

    except rospy.ROSInterruptException:
        print("❌ Script interrupted before completion.")


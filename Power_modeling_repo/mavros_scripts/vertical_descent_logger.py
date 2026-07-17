#!/usr/bin/env python3
import rospy, csv
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

# Callbacks
def vel_callback(msg):
    global vz
    vz = msg.twist.linear.z

def battery_callback(msg):
    global voltage, current
    voltage, current = msg.voltage, abs(msg.current)

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
rospy.init_node('vertical_descent_logger')

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
        print("🚀 Initializing vertical descent experiment with unequal altitude bands...")
        set_flight_mode('GUIDED')
        arm_drone()
        takeoff_drone(160)

        # Wait until UAV actually reaches ~160 m
        while current_alt < 159.0:
            rospy.sleep(1)
        print("✅ Reached 160 m, hovering...")
        rospy.sleep(5)  # hover stabilize

        filename = '/home/neha/ardupilot/ArduCopter/vertical_descent_data_unequal.csv'
        with open(filename, 'w') as f:
            writer = csv.writer(f)
            writer.writerow(["Timestamp", "Vz(m/s)", "Voltage(V)", "Current(A)", "Power(W)", "TargetVz(m/s)", "CurrentAlt(m)"])

            # Speeds 0.5 → 3.0 m/s in 0.5 steps
            descent_speeds = [i*0.5 for i in range(1,7)]
            # Unequal altitude bands: smaller for slow speeds, larger for fast speeds
            altitude_bands = [12, 12, 15, 20, 25, 30]  # total ≈114 m

            current_alt = 160.0
            for spd, band in zip(descent_speeds, altitude_bands):
                target_alt = max(2.0, current_alt - band)
                print(f"  Descending at {spd} m/s from {current_alt:.1f} → {target_alt:.1f} m")

                while current_alt > target_alt:
                    move_with_velocity(-spd)   # negative velocity for descent
                    ts = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
                    power = voltage * current
                    writer.writerow([ts, round(vz,3), round(voltage,3), round(current,3),
                                     round(power,3), -spd, round(current_alt,2)])
                    rospy.sleep(0.1)  # 10 Hz logging

                current_alt = target_alt
                print(f"✅ Finished descent segment at {spd} m/s → reached {current_alt:.1f} m")
                rospy.sleep(3)

        print(f"🎯 Unequal-band descent data logged successfully. CSV saved at: {filename}")

    except rospy.ROSInterruptException:
        print("❌ Script interrupted before completion.")


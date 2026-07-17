#!/usr/bin/env python3

import rospy
from geometry_msgs.msg import PoseStamped, TwistStamped
from sensor_msgs.msg import BatteryState
from mavros_msgs.srv import CommandBool, SetMode
import csv, time

# === Global variables ===
battery = None
velocity = None

def battery_cb(msg):
    global battery
    battery = msg

def velocity_cb(msg):
    global velocity
    velocity = msg.twist.linear

def main():
    rospy.init_node('vertical_ascent_experiment')

    # Publishers
    pos_pub = rospy.Publisher('/mavros/setpoint_position/local', PoseStamped, queue_size=10)
    vel_pub = rospy.Publisher('/mavros/setpoint_velocity/cmd_vel', TwistStamped, queue_size=10)

    # Subscribers
    rospy.Subscriber('/mavros/battery', BatteryState, battery_cb)
    rospy.Subscriber('/mavros/local_position/velocity_body', TwistStamped, velocity_cb)

    # Services
    rospy.wait_for_service('/mavros/cmd/arming')
    rospy.wait_for_service('/mavros/set_mode')
    arm_srv = rospy.ServiceProxy('/mavros/cmd/arming', CommandBool)
    mode_srv = rospy.ServiceProxy('/mavros/set_mode', SetMode)

    rate = rospy.Rate(10)  # 10 Hz logging

    # Initial setpoint
    pose = PoseStamped()
    pose.pose.position.x = 0
    pose.pose.position.y = 0
    pose.pose.position.z = 2  # hover start

    vel = TwistStamped()

    print("📡 Sending initial setpoints...")
    for _ in range(50):
        pos_pub.publish(pose)
        vel_pub.publish(vel)
        rate.sleep()

    print("⚙ Switching to GUIDED mode...")
    mode_srv(custom_mode="GUIDED")
    rospy.sleep(1)

    print("🔑 Arming drone...")
    arm_srv(True)
    rospy.sleep(2)

    print("✅ Drone armed, hovering at 2m...")

    # CSV setup
    file = open('/home/neha/ardupilot/ArduCopter/vertical_ascent_data.csv', 'w')
    writer = csv.writer(file)
    writer.writerow(['time','Vz','Voltage','Current','Power','Commanded_V'])

    # Ascent speeds 0 → 5 m/s
    ascent_speeds = [i*0.5 for i in range(11)]
    for v_cmd in ascent_speeds:
        print(f"\n🚀 Ascending at {v_cmd} m/s")

        # Duration to reach 110 m
        duration = 110.0/v_cmd if v_cmd>0 else 10.0
        start = time.time()

        while time.time() - start < duration:
            # Command altitude increasing linearly
            z = min(110.0, v_cmd*(time.time()-start))
            pose.pose.position.z = z
            pos_pub.publish(pose)

            if battery and velocity:
                Vz = velocity.z
                voltage = battery.voltage
                current = battery.current
                power = voltage*current
                writer.writerow([rospy.get_time(), Vz, voltage, current, power, v_cmd])

            rate.sleep()

        print(f"📁 Data collected for {v_cmd} m/s")
        rospy.sleep(5)

    file.close()
    print("\n✅ VERTICAL ASCENT EXPERIMENT COMPLETE")
    print("📊 Saved: vertical_ascent_data.csv")

if __name__ == '__main__':
    main()


#!/usr/bin/env python3

import rospy
from geometry_msgs.msg import TwistStamped, PoseStamped
from sensor_msgs.msg import BatteryState
from mavros_msgs.srv import CommandBool, SetMode
import csv
import time

# ================= GLOBAL VARIABLES =================
battery = None
velocity = None

def battery_cb(msg):
    global battery
    battery = msg

def velocity_cb(msg):
    global velocity
    velocity = msg.twist.linear

# ================= MAIN =================
def main():
    rospy.init_node('uav_experiment_final')

    # Publishers
    vel_pub = rospy.Publisher('/mavros/setpoint_velocity/cmd_vel', TwistStamped, queue_size=10)
    pos_pub = rospy.Publisher('/mavros/setpoint_position/local', PoseStamped, queue_size=10)

    # Subscribers
    rospy.Subscriber('/mavros/battery', BatteryState, battery_cb)
    rospy.Subscriber('/mavros/local_position/velocity_local', TwistStamped, velocity_cb)

    # Services
    rospy.wait_for_service('/mavros/cmd/arming')
    rospy.wait_for_service('/mavros/set_mode')

    arm_srv = rospy.ServiceProxy('/mavros/cmd/arming', CommandBool)
    mode_srv = rospy.ServiceProxy('/mavros/set_mode', SetMode)

    rate = rospy.Rate(10)  # 10 Hz logging

    # ================= INITIAL SETPOINT =================
    pose = PoseStamped()
    pose.pose.position.x = 0
    pose.pose.position.y = 0
    pose.pose.position.z = 20  # FIXED HEIGHT

    vel = TwistStamped()

    print("Sending initial setpoints...")

    for _ in range(100):
        pos_pub.publish(pose)
        vel_pub.publish(vel)
        rate.sleep()

    # ================= SET MODE + ARM =================
    mode_srv(custom_mode="GUIDED")
    rospy.sleep(1)

    arm_srv(True)
    rospy.sleep(2)

    print("✅ Drone armed, taking position at 20m...")

    # Hold position for stabilization
    for _ in range(100):
        pos_pub.publish(pose)
        rate.sleep()

    # ================= CSV SETUP =================
    file = open('experiment_data.csv', 'w')
    writer = csv.writer(file)
    writer.writerow([
        'time','Vx','Vy','Vz',
        'Voltage','Current','Power',
        'Commanded_V'
    ])

    # ================= SPEED LOOP =================
    speeds = list(range(0, 16))  # 0 → 15 m/s

    for v_cmd in speeds:

        print(f"\n🚀 Running at {v_cmd} m/s")

        # -------- STABILIZATION --------
        for _ in range(60):  # ~6 sec
            vel.twist.linear.x = v_cmd
            vel.twist.linear.y = 0
            vel.twist.linear.z = 0

            pos_pub.publish(pose)
            vel_pub.publish(vel)

            rate.sleep()

        print("✔ Stable → collecting data")

        # -------- DATA COLLECTION --------
        start = time.time()

        while time.time() - start < 15:

            if battery and velocity:

                Vx = velocity.x
                Vy = velocity.y
                Vz = velocity.z

                voltage = battery.voltage
                current = battery.current
                power = voltage * current

                # ===== STRONG FILTER =====
                if (
                    abs(Vx - v_cmd) < 0.3 and   # tight speed match
                    abs(Vy) < 0.1 and
                    abs(Vz) < 0.1
                ):
                    writer.writerow([
                        rospy.get_time(),
                        Vx, Vy, Vz,
                        voltage, current,
                        power,
                        v_cmd
                    ])

            # keep sending commands
            pos_pub.publish(pose)
            vel_pub.publish(vel)

            rate.sleep()

    file.close()

    print("\n✅ EXPERIMENT COMPLETE")
    print("📁 Saved: experiment_data.csv")

# ================= RUN =================
if __name__ == '__main__':
    main()

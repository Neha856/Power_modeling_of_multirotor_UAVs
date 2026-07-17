sudo apt update
passwd neha
sudo su
su -
exit
cd ~
ls
cd ardupilot
ls
cd ArduCopter
cd ~/ardupilot/ArduCopter
sim_vehicle.py -v ArduCopter -f quad --console --map
export DISPLAY=:0
sim_vehicle.py -v ArduCopter -f quad --console --map
sim_vehicle.py -v ArduCopter --map --consol -L iitk
echo "iitk=26.520285,80.232470,122,0" >> ~/ardupilot/Tools/autotest/locations.txt
sim_vehicle.py -v ArduCopter --map --consol -L iitk
rosversion -d
cd ~
rosversion -d
sudo sh -c 'echo "deb http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main" > /etc/apt/sources.list.d/ros-latest.list'
sudo apt install curl # if you haven't already installed curl
curl -s https://raw.githubusercontent.com/ros/rosdistro/master/ros.asc | sudo apt-key add -
sudo apt update
sudo apt install ros-noetic-desktop-full
source /opt/ros/noetic/setup.bash
echo "source /opt/ros/noetic/setup.bash" >> ~/.bashrc
source ~/.bashrc
echo "source /opt/ros/noetic/setup.bash" >> ~/.bashrc
source ~/.bashrc
sudo apt install python3-rosdep python3-rosinstall python3-rosinstall-generator python3-wstool build-essential
sudo apt install python3-rosdep
sudo rosdep init
rosdep update
sudo apt-get install python3-wstool python3-rosinstall-generator python3-catkin-lint python3-pip python3-catkin-tools
pip3 install osrf-pycommon
mkdir -p ~/catkin_ws/src
cd ~/catkin_ws
catkin init
cd ~/catkin_ws
wstool init ~/catkin_ws/src
rosinstall_generator --upstream mavros | tee /tmp/mavros.rosinstall
rosinstall_generator mavlink | tee -a /tmp/mavros.rosinstall
wstool merge -t src /tmp/mavros.rosinstall
wstool update -t src
rosdep install --from-paths src --ignore-src --rosdistro `echo $ROS_DISTRO` -y
sudo apt install ros-noetic-geographic-msgs
sudo apt install geographiclib-tools libgeographic-dev
rosdep install --from-paths src --ignore-src --rosdistro `echo $ROS_DISTRO` -y
sudo apt install geographiclib-tools libgeographic-dev ros-noetic-geographic-msgs
pip3 install --user future pymavlink
sudo geographiclib-get-geoids egm96-5
catkin build
echo "source ~/catkin_ws/devel/setup.bash" >> ~/.bashrc
source ~/.bashrc
cd ~/catkin_ws/src
git clone https://github.com/Intelligent-Quads/iq_sim.git
git clone https://github.com/Intelligent-Quads/iq_gnc.git
echo "GAZEBO_MODEL_PATH=${GAZEBO_MODEL_PATH}:$HOME/catkin_ws/src/iq_sim/models" >> ~/.bashrc
cd ~/catkin_ws
catkin build
echo export ROS_MASTER_URI=http://localhost:11311 >> ~/.bashrc
echo export ROS_HOSTNAME=localhost >> ~/.bashrc
source ~/.bashrc
source ~/catkin_ws/devel/setup.bash
echo export ROS_MASTER_URI=http://localhost:11311 >> ~/.bashrc
echo export ROS_HOSTNAME=localhost >> ~/.bashrc
source ~/.bashrc
cd ~
ls
cd /ardupilot/ArduCopter
cd ardupilot
ls
cd ArduCopter
sim_vehicle.py -v ArduCopter --map --consol -L iitk
cd ~
nano uav_experiment.py
chmod +x uav_experiment.py
python3 --version
mv ~/uav_experiment.py ~/catkin_ws/src/
cd ~
ls
cd ardupilot
ls
cd ArduCopter
export DISPLAY =:0
export DISPLAY=:0
sim_vehicle.py -v ArduCopter --map --consol -L iitk
nano uav_experiment.py
chmod +x uav_experiment.py
mv ~/uav_experiment.py ~/catkin_ws/src/
cd ~/ardupilot/ArduCopter
roscore
find ~ -name "uav_experiment.py"
rm ~/catkin_ws/src/uav_experiment.py
rm ~/ardupilot/ArduCopter/uav_experiment.py
find ~ -name "uav_experiment.py"
~/catkin_ws/src/
cd ~/catkin_ws/src
nano uav_experiment.py
chmod +x ~/catkin_ws/src/uav_experiment.py
source ~/catkin_ws/devel/setup.bash
python3 uav_experiment.py
gedit experiment_data.csv
cat experiment_data.csv
rostopic list
rostopic echo /mavros/battery
rostopic hz /mavros/battery
cd ~
ls
cd ardupilot
ls
cd ArduCopter
ls
cd logs
ls
cd ../
rostopic echo /mavros/state
cd ardupilot/ArduCopter
rostopic echo /mavros/state
netstat -tlnp | grep 5760
rostopic echo /mavros/state
cd ardupilot/ArduCopter
sim_vehicle.py -v ArduCopter --map --console -L iitk
export DISPLAY=:0
sim_vehicle.py -v ArduCopter --map --console -L iitk
cd ~
ls
cd ardupilot/ArduCopter
roscore
cd ardupilot/ArduCopter
roslaunch mavros apm.launch fcu_url:=tcp://127.0.0.1:5760
roslaunch mavros apm.launch fcu_url:=udp://127.0.0.1:14550
roslaunch mavros apm.launch fcu_url:=udp://@127.0.0.1:14550
cd ardupilot/ArduCopter
source /opt/ros/noetic/setup.bash
source ~/catkin_ws/devel/setup.bash
rostopic echo -n 1 /mavros/state
rosnode list
rostopic hz /mavros/state
rostopic list | grep mavros
mavproxy.py --master=tcp:127.0.0.1:5760
ps -ef | grep arducopter
ss -ltn | grep 5760
netstat -an | grep 5760
ss -ant | grep 5760
rostopic echo -n 1 /mavros/state
rostopic echo /mavros/state
hostname -I
rosparam get /mavros/fcu_url
ls
cd catkin_ws
ls
cd src
ls
cd mavros
ls
cd mavros
ls
cd launch
ls
vim apm2.launch
vim apm.launch
cd ardupilot/ArduCopter
export DISPLAY=:0
sim_vehicle.py -v ArduCopter --map --console -L iitk
./Tools/autotest/sim_vehicle.py -v ArduCopter --no-mavproxy --out 127.0.0.1:14550
sim_vehicle.py -v ArduCopter --no-mavproxy --out 127.0.0.1:14550
sim_vehicle.py -v ArduCopter --map --console -L iitk --out 127.0.0.1:14550
sim_vehicle.py -v ArduCopter --map --console
cd ardupilot/ArduCopter
roscore
cd ardupilot
cd ArduCopter
roslaunch mavros apm.launch fcu_url:=udp://@127.0.0.1:14550
roslaunch mavros apm.launch fcu_url:=udp://@127.0.0.1:14550 fcu_protocol:=v1.0
roslaunch mavros apm.launch
cd ardupilot/ArduCopter
sim_vehicle.py -v ArduCopter --map --console
export DISPLAY=:0
sim_vehicle.py -v ArduCopter --map --console
cd ardupilot/ArduCopter
cd ../../
ls
cd catkin_ws
ls
cd src
ls
cd mavros
ls
cd mavros
ls
cd scripts
ls
cd ardupilot/ArduCopter
rosrun mavros horizontal_flight_logger.py
cd ardupilot/ArduCopter
roslaunch mavros apm.launch
cd ardupilot/ArduCopter
roscore
ls
cd ardupilot
ls
cd ArduCopter
ls
vim horizontal_flight_data.csv
pwd
ls
rosrun mavros horizontal_flight_logger.py
ls
vim horizontal_flight_data.csv
ls
cd catkin_ws
ls
cd builds
cd build
ls
cd ../
cd src
ls
cd ../../
ls
cd ardupilot
ls
cd Tools
ls
cd autotest
ls
cd default_params
ls
vim copter.parm
cd ../../
cd ../
ls
cd libraries
ls
cd  SITL
ls
cd examples
ls
cd JSON
ls
cd pybullet
ls
cd model
cd models
ls
cd iris
ls
vim iris.urdf
cat iris.urdf
cd ../../../../../../
cd ../
ls
cd libraries
ls
cd catkin_ws
ls
cd src
ls
vim uav_experiment.py
cd ../../
cd ardupilot
ls
cd ArduCopter
ls
vim horizontal_flight_data.csv
sim_vehicle.py -v ArduCopter --map --console
cd ardupilot/ArduCopter
export DISPLAY=:0
sim_vehicle.py -v ArduCopter --map --console
cd ardupilot/ArduCopter
roscore
cd ardupilot
cd ArduCopter
ls
roslaunch mavros apm.launch
cd ardupilot/ArduCopter
source ~/catkin_ws/devel/setup.bash
python3 ~/catkin_ws/src/vertical_ascent.py
cd ardupilot/ArduCopter
roslaunch mavros apm.launch
cd ardupilot/ArduCopter
source ~/catkin_ws/devel/setup.bash
python3 ~/catkin_ws/src/vertical_ascent.py
ls
vim vertical_ascent_data.csv
cat vertical_ascent_data.csv
rm vertical_ascent_data.csv
export DISPLAY=:0
sim_vehicle.py -v ArduCopter --map --console
cd ardupilot/ArduCopter
roscore
cd ardupilot/ArduCopter
ls
vim vertical_ascent_data.csv
rm vertical_ascent_data.csv
ls
export DISPLAY=:0
sim_vehicle.py -v ArduCopter --map --console
cd ardupilot/ArduCopter
roscore
cd ardupilot/ArduCopter
roslaunch mavros apm.launch
cd ardupilot/ArduCopter
rosrun mavros vertical_ascent.py
source ~/catkin_ws/devel/setup.bash
rosrun mavros vertical_ascent.py
export DISPLAY=:0
sim_vehicle.py -v ArduCopter --map --console
cd ardupilot/ArduCopter
source ~/catkin_ws/devel/setup.bash
export DISPLAY=:0
sim_vehicle.py -v ArduCopter --map --console
cd ardupilot/ArduCopter
roscore
cd ardupilot/ArduCopter
roslaunch mavros apm.launch
cd ardupilot/ArduCopter
ls
export DISPLAY=:0
sim_vehicle.py -v ArduCopter --map --console
cd ardupilot/ArduCopter
roscore
cd ardupilot/ArduCopter
roslaunch mavros apm.launch
cd ardupilot/ArduCopter
export DIAPLAY=:0
sim_vehicle.py -v ArduCopter --map --console
cd ardupilot/ArduCopter
rosrun mavros vertical_ascent_logger.py
cp /home/neha/ardupilot/ArduCopter/vertical_ascent_data1.csv /mnt/c/Users/NEHA/OneDrive/Documents/
ls
cp /home/neha/ardupilot/ArduCopter/vertical_ascent_data.csv /mnt/c/Users/NEHA/OneDrive/Documents/
cd ardupilot/ArduCopter
rosrun mavros vertical_ascent_logger1.py
ls
vim vertical_ascent_data_adaptive.csv
rm vertical_ascent_data_adaptive.csv
rosrun mavros vertical_ascent_logger1.py
vim vertical_ascent_data_balanced.csv
rosrun mavros vertical_ascent_logger.py
ls
vim vertical_ascent_data1.csv
rm vertical_ascent_data1.csv
ls
rosrun mavros vertical_ascent_logger1.py
vim vertical_ascent_data_balanced.csv
rosrun mavros vertical_ascent_logger1.py
vim vertical_ascent_data_balanced1.csv
rosrun mavros vertical_ascent_logger1.py
la
ls
cd catkin_ws
ls
cd src
cd mavros
cd scripts
ls
vim vertical_ascent_logger1.py
ls
chmod +x vertical_ascent_logger1.py
vim vertical_ascent_logger1.py
chmod +x vertical_ascent_logger1.py
vim vertical_ascent_logger1.py
chmod +x vertical_ascent_logger1.py
vim vertical_ascent_logger1.py
chmod +x vertical_ascent_logger1.py
vim vertical_ascent_logger1.py
chmod +x vertical_ascent_logger1.py
cd ardupilot/ArduCopter
rosrun mavros vertical_ascent_logger1.py
vim vertical_ascent_data_balanced2.csv
cp /home/neha/ardupilot/ArduCopter/vertical_ascent_data_balanced2.csv C:\Users\NEHA\OneDrive\Documents
cp /home/neha/ardupilot/ArduCopter/vertical_ascent_data_balanced2.csv /mnt/c/Users/NEHA/OneDrive/Documents/
cd ardupilot/ArduCopter
roslaunch mavros apm.launch
cd ardupilot/ArduCopter
roscore
cd ardupilot/ArduCopter
export DISPLAY=:0
sim_vehicle.py -v ArduCopter --map --console
cd catkin_ws/src/mavros/mavros/scripts
ls
cd ../
ls
cd launch
ls
cd ../
cd src
ls
cd mavros
ls
cd ../
ls
cd ../
cd ../../
cd ardupilot/ArduCopter
cd ../
ls
cd build
ls
cd sitl
ls
cd bin
ls
cd arducopter
cd ../../../
cd Tools
ls
cd scripts
ls
cd ../../
cd libraries
ls
cd ../
cd ArduCopter
ls
cd logs
ls
cd ../../
cd Tools
ls
cd autotest
ls
cd default_params
ls
vim copter.parm
cd ../../../
ls
cd ArduCopter
ls
vim mav.parm
cd logs
ls
vim 00000001.BIN
cd ../
ls
vim  mav.parm
cd ../
ls
cd libraries/SITL
ls
vim SIM_Multicopter.cpp
vim SIM_Frame.h
vim SIM_Frame.cpp
cd ../../
cd ArduCopter
export DISPLAY=:0
sim_vehicle.py -v ArduCopter --map --console
cd ../
cd libraries/SITL
ls
cd SIM_Multicopter.cpp
vim SIM_Multicopter.cpp
vim SIM_Frame.cpp
cd ../../
cd ArduCopter
sim_vehicle.py -v ArduCopter --map --console
cd ../
cd libraries/SITL
ls
cd examples
l
ls
cd JSON
ls
cd pybullet
ls
cd models
ls
cd iris
ls
vim iris.urdf
cd ~
cd ardupilot
cd Tools/autotest/default_params

vim copter.parm
cd ../
ls
cd models
ls
vim Callisto.json
cd ../../
cd ../
cd libraries/SITL
ls
vim SIM_QuadPlane.cpp
cat SIM_Multicopter.cpp
cat SIM_Frame.cpp
cat SIM_Frame.h
cd catkin_ws
ls
cd src/mavros/mavros/scripts
ls
vim vertical_ascent_logger.py
vim vertical_ascent_logger1.py
vim vertical_ascent_logger.py
cat vertical_ascent_logger.py
nano vertical_ascent_iris.py
chmod +x vertical_ascent_iris.py
ls
rm vertical_ascent_iris.py
ls
vim vertical_ascent_logger1.py
cat vertical_ascent_logger1.py
nano vertical_descent_logger
ls
rm vertical_descent_logger
nano vertical_descent_logger.py
chmod +x vertical_descent_logger.py
ls
cd ardupilot/ArduCopter
ls
sim_vehicle.py -v ArduCopter -f quad --frame=iris --map --console
export DISPLAY=:0
sim_vehicle.py -v ArduCopter --model iris --map --console
cd ../
ls
cd libraries/SITL
ls
vim SIM_Frame.h
vim SITL.h
vim SIM_JSON.h
vim SIM_QuadPlane.cpp
cd examples
ls
cd JSON
ls
cd pybullet
ls
cd models
ls
cd quadruped
ls
vim quadruped.urdf
cd ../
cd iris
ls
vim iris.urdf
cd ../../../../
cd ../../../
cd ArduCopter
export DISPLAY=:0
sim_vehicle.py -v ArduCopter --map --console
cd ardupilot/ArduCopter
rosrun
roscore
cd ardupilot/ArduCopter
roslaunch mavros apm.launch
cd catkin_ws/src/mavros/mavros/scripts
ls
vim vertical_ascent_logger1.py
cd catkin_ws/src/mavros/mavros/scripts
ls
vim vertical_descent_logger.py
cd ardupilot/ArduCopter
rosrun mavros  vertical_descent_logger.py
rosrun mavros vertical_descent_logger.py
python3 ~/catkin_ws/src/mavros/mavros/scripts/vertical_descent_logger.py
vim vertical_descent_data.csv
cd ardupilot/ArduCopter
ls
rm vertical_descent_data.csv
nano vertical_descent_data1.csv
chmod +x vertical_descent_data1.csv
rm vertical_descent_data1.csv
ls
vim vertical_descent_data1.csv
cd ardupilot/ArduCopter
sim_vehicle.py -v ArduCopter --map --console
export DISPLAY=:0
sim_vehicle.py -v ArduCopter --map --console
cd ardupilot/ArduCopter
roscore
cd ardupilot/ArduCopter
rosrun mavros horizontal_flight_logger2.py
ls
vim horizontal_flight_data_part2.csv
rosrun mavros horizontal_flight_logger2.py
ls
vim horizontal_flight_data_part2.csv
rosrun mavros horizontal_flight_logger2.py
vim horizontal_flight_data_part2.csv
rosrun mavros horizontal_flight_logger2.py
vim horizontal_flight_data_part2.csv
rosrun mavros horizontal_flight_logger2.py
vim horizontal_flight_data_part2.csv
rosrun mavros horizontal_flight_logger2.py
vim horizontal_flight_data_part2.csv
rosrun mavros horizontal_flight_logger.py
vim horizontal_flight_data_full.csv
cd ardupilot
ls
cd libraries/SITL

vim SIM_Frame.h
cd ardupilot
ls
cd libraries
ls
cd SITL
ls
vim SIM_Frame.h
vim SIM_Motor.h
vim SIM_Battery.h
vim SIM_Aircraft.h
vim SIM_Frame.cpp
vim SIM_Frame.h

cd ~/ardupilot
./waf configure --board sitl
./waf copter
cd ardupilot/ArduCopter
roscore
cd ardupilot/ArduCopter
rosrun mavros horizontal_flight_logger1.py
ls
vim horizontal_flight_data_part1.csv
vim horizontal_flight_data_part2.csv
pwd
cp me/neha/ardupilot/ArduCopter/horizontal_flight_data_part1.csv /mnt/c/Users/NEHA/Downloads
cp home/neha/ardupilot/ArduCopter/horizontal_flight_data_part1.csv /mnt/c/Users/NEHA/Downloads
cp /home/neha/ardupilot/ArduCopter/horizontal_flight_data_part1.csv /mnt/c/Users/NEHA/Downloads
cp /home/neha/ardupilot/ArduCopter/horizontal_flight_data_part2.csv /mnt/c/Users/NEHA/Downloads
cd catkin_ws/src/mavros/mavros/scripts
ls
vim horizontal_flight_logger1.py
vim horizontal_flight_logger2.py
vim vertical_ascent_logger1.py
vim vertical_ascent_logger.py
vim vertical_ascent_logger1.py
cd catkin_ws/src/mavros/mavros/scripts
ls
vim horizontal_flight_logger.py
cat horizontal_flight_logger.py
nano horizontal_flight_logger_10.py
chmod +x horizontal_flight_logger_10.py
ls
vim horizontal_flight_logger_10.py
cat horizontal_flight_logger_10.py
nano horizontal_flight_logger_15.py
chmod +x horizontal_flight_logger_15.py
ls
vim horizontal_flight_logger_15.py
cd ardupilot/ArduCopter
roscore
cd ardupilot/ArduCopter
rosrun mavros horizontal_flight_logger2.py
ls
vim horizontal_flight_data_part2.csv
rosrun mavros horizontal_flight_logger2.py
ls
vim horizontal_flight_data_part2.csv
vim horizontal_flight_data_full.csv
rm horizontal_flight_data_full.csv
vim horizontal_flight_data.csv
ls
rosrun mavros horizontal_flight_logger.py
vim horizontal_flight_data_full.csv
pwd
cp /home/neha/ardupilot/ArduCopter/horizontal_flight_data_full.csv /mnt/c/Users/NEHA/Downloads
rosrun mavros horizontal_flight_logger_10.py
vim horizontal_flight_data_10.csv
cp /home/neha/ardupilot/ArduCopter/horizontal_flight_data_10.csv /mnt/c/Users/NEHA/Downloads
rosrun mavros horizontal_flight_logger_10.py
vim horizontal_flight_data_10.csv
rosrun mavros horizontal_flight_logger_15.py
vim horizontal_flight_data_15.csv

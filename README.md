![OWLS](images/owls.jpg?raw=true "OWLS")
# OWLS (Open WiFi Load Simulator)
This is a distrubuted system for creating load on a OpenWIFI system. The goal is to generate load over time, keep statistics
on time-outs, response times, and number of concurrent users. The system maybe distributed over several nodes to provide multiple 
realtime numbers.

## Getting started
### Hardware and software
This simulator requires multiple machines to run. Now, it can be bare-metal or VMs. It does not really matter. Since the goal 
is to stress server resourcess, we would suggest to run the TIP on a much larger machine and these simulation node on VMs. 
As for support, this was developed on Debian based Linux distributions (Ubuntun and Debian). We have also done extensive 
testing on Mac OS X. Windows is not supported currently and there is no plans on supporting it.

### Security
This simulator should run behind your firewalls. There is no security between the management UI and the simulation manager. 
You could run the simulation entirely behind a firewall and run the TIP controller in the cloud. 

### Pre-requisites
This simulator uses Erlang. This language is designed to support thousands of processesand very suitable for this task. 
You must install Erlang OTP 22 or newer in order to run this application.
#### Linux 
##### Ubuntu
```
sudo apt install erlang
```
##### Other Linux distributions
Please visit https://www.erlang-solutions.com/resources/download.html in order to get instructions for 
other Linux distributions and operating systems.

#### OS X
```
brew install erlang 
```

#### From source
Please visit https://erlang.org/doc/installation_guide/INSTALL.html to build Erlang from scratch.

#### Windows
Their is currently no plan to support Windows based hosts.

### Verifying if Erlang is available
From the command line, simply type 
```
prompt > erl
```
Your should see something like this
```
Erlang/OTP 23 [erts-11.1.1] [source] [64-bit] [smp:16:16] [ds:16:16:10] [async-threads:1] [hipe] [dtrace]

Eshell V11.1.1  (abort with ^G)
1>
```
 To exit, enter `q().`, like this
 ```
 Erlang/OTP 23 [erts-11.1.1] [source] [64-bit] [smp:16:16] [ds:16:16:10] [async-threads:1] [hipe] [dtrace]

Eshell V11.1.1  (abort with ^G)
1> q().
ok
2>                                                                                
prompt >
```
### Compiling the code
You need to clone the repository, run a configuration command, and start doing the simulation

```
git clone https://github.com/telecominfroproject/wlan-cloud-loadsim
cd wlan-cloud-loadsim
```

### Choosing a node type
In a simulation, you have 3 types of nodes. 

#### `simmanager` node
There is only one `simmanager` node. This node is responsible for directing all the other nodes in the simulation. It is a 
central management point and gathers all the data about the simulation. You will be interacting with the `simmanager` through a 
command line interface or a web UI. If you wish to start a `simmanager` node, you should do the following and answer the questions
for the initial configuration.

```
./simmanager_config
./simnanager
```

#### `simnode` node
You can have multiple `simnode` nodes. Each of these nodes can be started on the same host, or a number of other virtual or physical machines.
Once a `simnode` is running, you will be able to monitor it trough a command line interface or a local web UI. If you wish to start a `simnode`, please 
follow these instructions and answer the questions for the initial configuration.

```
./simnode_config
./simnode
```

#### `simmonitor` node
You should have a single 'simmonitor' node. This node is intended to run on the actual TIP controller server. It's only purpose in life is to report OS details back into the 'simmanager' node. This is then displayed in the UI to monitor the laod experienced on the TIP controller server.

```
./simmonitor_config
./simmonitor
```

#### On running multiple node types on a single machine
If you wish to run multiple nodes on a single host, you should run this from multiple copies of the repository code. 

```
mkdir ~/projects
cd ~/projects
mkdir simnode1
cd simnode1
git clone https://github.com/telecominfraproject/wlan-cloud-loadsim
cd wlan-cloud-loadsim
./simnode_config
./simnode
```

in another terminal window

```
cd ~/projects
mkdir simnode2
cd simnode2
git clone https://github.com/telecominfraproject/wlan-cloud-loadsim
cd wlan-cloud-loadsim
./simnode_config
./simnode
```

If you want to run multiple nodes on a single machine, you need to make sure that your number numbers are all different. 
If you run multiple on the same machine within different VMs, the node number is not as important. 

#### Simple check on each node
In order for all the nodes to participate in the simulation, you should start all the nodes with the proper node 
type for the local node by running either 'simmanager', 'simnode', or 'simmonitor'. Now from the prompt, 
you should be able to type the following:

```erlang
(simmonitor10@host1.local)1> nodes().
['simmanager@host1.local',
'simnode1@host2.local']
(simmonitor10@host1.local)2>
```

It will take about 10-30 seconds for all the nodes to be visible. If you see all the nodes, you should now 
proceed on planning your simulation. If some nodes are missing, you should use `ping hostname` to see if the nodes 
are visible and able to reach other by name. You must be using names. You should modify `/etc/hosts` file
in order to make sure that you can reach each host participating in the simulation by name. 

#### About the Network cookie
For nodes to accept communication between each other, they must share the same `cookie`. You can change this 
in the `config/simmanager.args` or the `config/simnode.args`. The `cookie` provides light security for
each nodes behind the firewall.

```erlang
-setcookie oreo
```

Whatever value you pick, you will need to enter the same value on all the additional hosts (`simmanager`,
`simmonitor`, and `simnode`) that will participate in this simulation. In the case, replace `oreo` with your favorite 
password. Please note that this simulation is not meant to run across the internet and is expected to run behind 
firewalls. Security is beyond the scope of this project.

## Your CA (Certificate Authority)
When you configured your TIP Controller, you created a number of keys and certificates. In order for this simulator to
create keys and certificates that are compatible with your installation of the TIP controller, you will need to import
the CA key and the certificate. Make sure you have the password you used during that configuration. Usually, that password 
has been set to 'mypassword'. You will need this information to import your CA in the UI.

## Planning the simulation
In order to create a successful simulation, a bit of planning is necessary. Here is what you will need:
- 1 `simmanager` node
- 1 or more `simnode`
- 1 `simmonitor` node

Whether the node is a `simmanager`,`simnode`, or `simmonitor`, you will need to have a copy of this repository. Therefore, 
if you use different physical hosts, you just need to clone this repository. If you plan on running multiple nodes on 
a single host, you should clone this repo in a separate directories for each node.

### Creating the `simmanager` node
In order to create the `simmanager` you need to clone the repo and launch the `simmanager_config` command. The command will ask you 
for several questions. In many cases the default values are just fine. Here's an example:

```
cd ~
github clone https://github.com/stephb9959/owls
cd owls
./simmanager_config
Please enter a node name [simmanager@renegademac.arilia.com] :
Please enter a network cookie [oreo] :
Please enter a directory name [/Users/stephb/Desktop/Dropbox/dhcp/test_repos3/owls] :
Please enter the WEB UI port [9090] :
```
All the values between brackets are the default values. The most important value is the host part of the node name. You must be able 
to `ping` any host used as a node for this simulation. 

Once the `simmanager` is started, you should be able to start it like this:
```
./simmanager
heart_beat_kill_pid = 17839
Erlang/OTP 23 [erts-11.1.1] [source] [64-bit] [smp:16:16] [ds:16:16:10] [async-threads:5] [hipe] [dtrace]

Eshell V11.1.1  (abort with ^G)
(simmanager@renegademac.arilia.com)1>
```
The prompt should show the node name you entered when you configured the node initially.

### Creating the `simnode` nodes
In order to create the `simnode` nodes you need to clone the repo and launch the `simnode_config` command. 
The command will ask you for several questions. In many cases the default values are just fine. Here's an example:

```
cd ~
github clone https://github.com/stephb9959/owls
cd owls
./simnode_config
Please enter a node number(1..99) [1] :
Please enter a node name [simnode1@renegademac.arilia.com] :
Please enter a network cookie [oreo] :
Please enter a directory name [/Users/stephb/Desktop/Dropbox/dhcp/test_repos3/owls] :
Please enter the WEB UI port(9096..9196) [9096] :
Please enter the OVSDB reflector port [6643] :
Please enter the OVSDB port [6640] :
```
All the values between brackets are the default values. The most important value is the host part of the node name. 
You must be able to `ping` any host used as a node for this simulation. 

Once the `simnode` is started, you should be able to start it like this:
```
./simnode
heart_beat_kill_pid = 17839
Erlang/OTP 23 [erts-11.1.1] [source] [64-bit] [smp:16:16] [ds:16:16:10] [async-threads:5] [hipe] [dtrace]

Eshell V11.1.1  (abort with ^G)
(simnode1@renegademac.arilia.com)1>
```

### Creating the `simmonitor` node
The `simmonitor` node does nothing really. It is useful to report the amount of memory and additional resources are
available on the TIP controller. To configure the `simmonitor` node, simply do the following:

```
user/home > ./simmonitor_config
```

Please answer the simple questions.

## How to run a simulation
You should start the UI by entering http://<host of the 'simmanager' node>. You should get something similar to the 
following screen (some slight changes may have occurred since the release of the document).

## The steps

### Import you CA first
Using the dialog, please use your `cakey.pem` and `cacert.pem` files and import the CA. Let's give the CA the name of 
`sim1`. 

### Create the simulation
A simulation must have a name, like '`sim`. No spaces are allowed. Enter the name of the CA you created in the previous step.
Enter the number of APs you want to simulate. Depending on the size of your TIP controller, you should select the proper number.
Let's choose 100 for this setup.

- Name: the simulation name.
- CA: the name of the CA your created in the previous step
- Number of devices: the number of Access Points you want to simulate (100 to start).
- Server name: the name of your TIP controller server. You must be able to ping that name from each node in your simulation.
- Port: the port to use for the TIP controller. 6643 is usually the default. 

Once the simulation record is created, you are one step closer. 

### Prepare the assets
Onec the simulation parameters have been established (previous step), now you need to create the actual Access Points. 
You do this with `prepare assets`. Just make sure you select the simulation name from the previous step. This step may take 
some time, depending on how many APs you are creating. (200 may take 1-2 minutes).

### Push the simulation 
Once all the assets are created and exist, you need to push them to the `simnode` nodes. Just press the `push assets` 
buton and select your simulation name. This step is very quick usually. (less than 5 seconds for 2,000 devices)

### Start the simulation
This will tell all the `simnode` nodes to start their set of APs. And this is where the magic happens. At this point,
the simulation nodes will start chatting with your TIP controller. You should start to see devices and access points 
appear when you select the `network` menu choice. Be mindful that the TIP controller may take several seconds or maybe minutes 
to display all the data the load simulator produces. 

## API
This project uses OpenAPI specification 3.0.03, and you can use Swagger (https://editor.swagger.io/) in order to 
look at the API located in the `api` directory. This API also follows the best practices for REST APi discussed in
https://github.com/NationalBankBelgium/REST-API-Design-Guide/wiki. 

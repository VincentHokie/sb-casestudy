# Simple python application for safeboda casestudy #

## Requirements ##

- Unix machine i.e. MacOS / Linux
- VirtualBox (default virtualization software used by minikube)

We'll also need these (the script will catch absence of these)

- Docker
- minikube (latest version i.e. **v1.1.0**)
- kubectl

## Getting up and running ##

There is a script that will allow you run this cluster i.e. start_safeboda_services.sh

to run it

- navigate to this folder on the terminal
- run the script i.e. `./start_safeboda_services.sh`

Once the script is run, it will show you the urls you can use to access the services locally i.e. python hello world + kibana dashboard

You will be prompted for a password, this is used to give minikube the permission to use the service IP addresses locally.

this is what success looks like

``` bash
Status:
	machine: minikube
	pid: 52577
	route: 10.96.0.0/12 -> 192.168.99.103
	minikube: Running
	services: [safeboda, kibana]
    errors:
		minikube: no errors
		router: no errors
		loadbalancer emulator: no errors
```

### Note ###

- the kibana setup is very barebones in this configuration but some logs can be seen with index setup

## Cleaning up ##

There is a script that will allow you cleanup this cluster i.e cleanup_created_resources.sh

- navigate to this folder on the terminal
- run the script i.e. `./cleanup_created_resources.sh`

## Areas of improvement ##

- make docker image smaller (possibly using alpine as the base)
- use SSL cert with nginx (blocker here was needing a constant IP/ FQDN)
- harden nginx configuration to e.g. prevent Cross-Site scripting and clickjacking
- error handling when starting services e.g.

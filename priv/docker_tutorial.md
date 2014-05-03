# Docker As Elixir Development Environment

I've struggled with Elixir's versioning system recently, but that's what what you get when living in bleeding edge area like Elixir. When I'm trying to use `postgrex` and `ecto`, there is a certain Elixir version required. For example, `postgrex` needs Elixir version "0.13.1-dev". I can install it by cloning Elixir's github repository, but I'm afraid to break my previous Elixir projects. 

That's when Docker came to mind.

## What Is Docker

Docker is a 'Linux Container Engine'. Think Virtual Machine, but smaller, faster, and practically zero startup/shutdown time.

Docker is a virtual machine on steroids. If you've ever run a virtual machine such as [VirtualBox](https://www.virtualbox.org), or even [Vagrant](http://www.vagrantup.com), you know how memory consuming it can be. If you want to experiment with a different version of, let's say, Elixir without harming your main system, Docker is your solution.

## Install Docker

Docker can run from virtually anywhere, so long as "anywhere" means on a Linux machine with a current version of the kernel :)

As far as I know, on Mac or Windows Docker will run inside a Linux virtual machine using VirtualBox. And VirtualBox will present the result on the terminal.

I run an Ubuntu-based operating system called [elementaryOS](http://elementaryos.org), so I was able to install Docker fairly easily:

	$ sudo apt-get install software-properties-common
	$ sudo add-apt-repository ppa:dotcloud/lxc-docker
	$ sudo apt-get update
	$ sudo apt-get install lxc-docker

If you're on a Mac or Windows, there are [more detailed instructions for your situation available on the Docker site](http://www.docker.io/gettingstarted/).

## Playing With Docker

Get the base image from the registry and start playing with it.

	$> docker pull base

And now if I do `$> docker images`, it will show me lists of images that I have in the local repository.

	base                   latest              b750fe79269d        13 months ago 180.1 MB
	base                   ubuntu-12.10        b750fe79269d        13 months ago 180.1 MB
	base                   ubuntu-quantal      b750fe79269d        13 months ago 180.1 MB
	base                   ubuntu-quantl       b750fe79269d        13 months ago 180.1 MB


Even though I just pulled one image called base, you'll notice it shares an image ID with another.  That's because it's the same image but with a different tag name.

Let's run another useful command.

	$> docker ps

This command will show you the container that is currently running. Since we are not running any containers yet, it's empty.

Now let's run our container:

	$> docker run base echo Hello
	Hello

Even though `Hello` printed in our terminal, it's actually run inside the container and came back to give us the result.

Let's run another example to tell us the differences between our machine and container that we made before. We used the base image, which is based on Ubuntu 12.10.  My machine is elementary OS Luna (based on Ubuntu 12.04). We use command `lsb_release` on Ubuntu to check the versions.
	
	$> lsb_release -a
	No LSB modules are available.
	Distributor ID: elementary OS
	Description:    elementary OS Luna
	Release:        0.2
	Codename:       luna

Then we run the same command in our base container.

	$> docker run base lsb_release -a
	Distributor ID: Ubuntu
	Description:    Ubuntu 12.10
	Release:        12.10
	Codename:       quantal
	No LSB modules are available.

See the magic?! My machine is eOS, but I have the power of Ubuntu 12.10 in my hand! Let's do something even more crazy. First, we choose the image from [the Docker repository](https://index.docker.io/) with a search for 'centos'.

	$> docker pull centos
	Pulling repository centos
	0b443ba03958: Download complete
	539c0211cd76: Download complete
	511136ea3c5a: Download complete
	7064731afe90: Download complete

Then we run something inside our centos container:

	$> docker run centos cat /etc/redhat-release                                                                                              
	CentOS release 6.5 (Final)

Boom! We are running Ubuntu-based OS and CentOS almost at the same time.

## Installing Elixir Inside A Container

Even though we can use Docker for almost every programming language you can think of, we will run a different version of Elixir on the different OS. This blog is dedicated to Elixir, after all.

### Installing Erlang And Dependencies

First, we install Erlang dependencies for centos/redhat.

	$> docker run centos yum install gcc glibc-devel make ncurses-devel openssl-devel autoconf


	...
	...
	Total download size: 35 M
	Installed size: 84 M
	Is this ok [y/N]: Exiting on user Command

Because yum needs confirmation, the container exited. We can add parameter `-y` to yum to skip the confirmation, but let me introduce an interactive mode in Docker.
	
	$> docker run -i -t centos /bin/bash 
	bash-4.1#

The difference here is that we add the `-i` and `-t` parameters to the `docker run` command. `-i` stands for interactive mode and `-t` will attach tty to our own tty so we can run commands inside our container. 

Now, we can re-run the yum command:

	bash-4.1# yum install gcc glibc-devel make ncurses-devel openssl-devel autoconf

	...
	...

	Total download size: 35 M
	Installed size: 84 M
	Is this ok [y/N]: y

Now instead of exited, we can input `y` to confirm the installation.

And while it's installing, let's open a new terminal and type `$> docker ps`.

	CONTAINER ID        IMAGE               COMMAND             CREATED      STATUS              PORTS               NAMES
	224ae2931108        centos:centos6      /bin/bash           6 minutes ago      Up 6 minutes 

It will show you all your current containers that are still running. Now let's go back to our container's terminal and continue to install Erlang. Get the latest version of Erlang and download it.

	bash-4.1# wget https://packages.erlang-solutions.com/erlang/esl-erlang-src/otp_src_17.0.tar.gz --no-check-certificate
	bash: wget: command not found

Crap! `wget` is not installed yet. Do install it now, please...

	bash-4.1# yum install -y wget tar
	bash-4.1# wget https://packages.erlang-solutions.com/erlang/esl-erlang-src/otp_src_17.0.tar.gz --no-check-certificate
	bash-4.1# tar zxvf otp_src_17.0.tar.gz
	bash-4.1# cd otp_src_17.0
	bash-4.1# ./configure && make && make install

Now, we run erlang:

	bash-4.1# erl
	Erlang/OTP 17 [erts-6.0] [source] [64-bit] [smp:4:4] [async-threads:10] [hipe] [kernel-poll:false]

	Eshell V6.0  (abort with ^G)
	1>

Cool! We have Erlang 17. Now we can install the latest version of Elixir. But before that, we should install git first.

	bash-4.1# yum install git

With git installed, we can get the latest version of Elixir:

	bash-4.1# git clone https://github.com/elixir-lang/elixir.git
	bash-4.1# cd elixir
	bash-4.1# make clean test

And, if everything is ok, we now can access the latest version of Elixir.

	$> bin/iex
	Erlang/OTP 17 [erts-6.0] [source] [64-bit] [smp:4:4] [async-threads:10] [hipe] [kernel-poll:false]

	Interactive Elixir (0.13.1-dev) - press Ctrl+C to exit (type h() ENTER for help)
	iex(1)>

Wow! Now we have Elixir version 0.13.1-dev to experiment with.

## Commit The Change
Before exiting the container, we should save the container so we can use it in the future. If we exit without committing the changes, everything we did will disappear. Open another terminal and type the command below:

	$> docker images
	REPOSITORY             TAG                 IMAGE ID            CREATED     VIRTUAL SIZE
	centos                 latest              730cde6d6cae        2 minutes ago  1.097 GB
	centos                 centos6             0b443ba03958        9 days ago     297.6 MB
	centos                 latest              0b443ba03958        9 days ago     297.6 MB

Take the repository id, commit it, and name it `elixir`.

	$> docker commit 730cde6d6cae elixir 

Now when we run `docker images` we can see the `elixir` container has saved to our local docker repository.
	
	$> docker images
	REPOSITORY             TAG                 IMAGE ID            CREATED     VIRTUAL SIZE
	elixir                 latest              730cde6d6cae        2 minutes ago  1.097 GB
	centos                 centos6             0b443ba03958        9 days ago     297.6 MB
	centos                 latest              0b443ba03958        9 days ago     297.6 MB


We go back to our Elixir container `bash` if we exit from interactive mode by typing command `exit`. We will have two versions of Elixir without screwing up each other. Let's write an Elixir script and test it on two different versions that we have.

	defmodule Hello do
		IO.inspect System.version
	end
	[hello.exs]

The script is simple enough. We print the version of Elixir to check what Elixir version we are running.

Let's run it locally:

	$> elixir hello.exs
	"0.13.0-dev"

To share a file between host machine and container, we can mount a directory to a container using the `-v` parameter. After we mount to a directory, we run the file.

	$ docker run -v /home/riza/Documents/FunProjects/elixir/elixirdose/docker:/root:ro elixir /elixir/bin/elixir /root/hello.exs
	"0.13.1-dev"

Boom! We have two different versions of Elixir, 0.13.0-dev on the local machine and 0.13.1-dev in a container. And any time you need to test an Elixir project with different versions, you can use Docker to help you out.

## References
* http://www.coolgarif.com/blog/using-docker-as-a-development-environment
* http://pyvideo.org/video/2629/introduction-to-docker
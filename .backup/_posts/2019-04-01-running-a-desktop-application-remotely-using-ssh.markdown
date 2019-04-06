---
layout: post
title:  "Running a desktop application remotely using SSH"
date:   2019-04-01 21:48:46 MDT
categories: guides
---
This is a guide on how to set up a Cygwin SSH server to run an application on the desktop of a remote Windows machine. This allows for easy automation, plus some pretty nice April fools jokes ;)

### Setup the SSH server:

Using the remote host:

1. Download [the Cygwin executable](https://www.cygwin.com/setup-x86_64.exe), and run it using an account with administrator privileges.
  - Use any mirror you want - you might encounter issues with the ftp mirrors, so I recommend using the http versions.
2. Search and select the latest version of `openssh`. For this guide, we will be using `7.9p1-1`, however the process should be the same regardless of version.
3. After installing, run the Cygwin Terminal using administrator privileges. (Start Menu -> Cygwin64 Terminal -> Right-click -> Select 'Run as Administrator')
4. Be careful on this step. Type `ssh-host-config` in the elevated terminal. For the questions:
  - StrictModes yes
  - Create Account no

  ssh-host-config should then return an error after step 2. _You can ignore this_, we want to be running the executable under our current administrator account.
5. Run the command:
`echo "/usr/sbin/sshd.exe && echo \"Started SSH server\"" | tee -a ~/.bashrc > /dev/null` in your home directory. This command will, when you run your terminal, start an SSH server as an sshd process under your Windows user. 

At this point, with the Cygwin terminal still running on the remote host, you should be able to ssh into the remote host and run applications (for instance, try executing `notepad` in a ssh shell).

### Setting up server for persistence:

1. Make sure your user account you run Cygwin under is set to automatically log-in, if you are using the remote host as a server. Check [this guide](https://www.tenforums.com/tutorials/3539-sign-user-account-automatically-windows-10-startup.html) for more information on how to do this.
2. Press Start Key + R, and open the Run prompt. Type `taskschd.msc`. In the right-hand column of the Task Scheduler, click 'Create Task'. 
  - In the `General` tab, in the "Name" field, call it whatever you wish ("SSH Server" works well)
  - On the bottom, check "Run with highest privileges"
  - In the `Triggers` tab, click "New...", and in the dropdown "Begin the task", select "At log on", and select "Specific user:" == your user.
  - In the `Actions` tab, click "New...", and in the "Program/script:" field, copy and paste `C:\cygwin64\bin\mintty.exe`. In the "Add arguments (optional):" field beneath it, type `-i /Cygwin-Terminal.ico -`, and click "OK".

Now, at the next log-on of your User, Cygwin should start the SSH server and enable the launching of GUI applications. 

Hopefully this guide helped out (:

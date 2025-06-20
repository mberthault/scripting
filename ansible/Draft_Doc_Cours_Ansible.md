# Documentation sur les points complexes du cours **Ansible For Devops**

## Installer Vagrant sur un système WSL, avec prise en charge du provisioning via Ansible

> N'ayant pas de homelab Linux à la maison, je passe par un WSL sur mon Windows 11.
>
> En plus d'être nécessaire dans mon cas, le challenge est stimulant et intéressant.
>
> Étonnament, il est difficile de trouver de l'information sur ce sujet.
>
> Le site officiel de Hashicorp indique d'ailleurs :
>> Warning: Advanced Topic! Using Vagrant within the Windows Subsystem for Linux is an advanced topic that only experienced Vagrant users who are reasonably comfortable with Windows, WSL, and Linux should approach.

### Sources d'information utilisées

* ℹ️ On se base sur le livre [Ansible For Devops](http://leanpub.com/ansible-for-devops) par Jeff Geerling

* Vagrant and Windows Subsystem for Linux :
	* https://developer.hashicorp.com/vagrant/docs/other/wsl (doc officielle)
	* https://thenets.org/how-to-run-vagrant-on-wsl-2/
	* https://nicksantos.com/2020/05/ansible-deploys-from-windows-using-wsl-hyper-v-and-vagrant/

* Permissions sur les disques Windows sous wsl :
	* https://www.turek.dev/posts/fix-wsl-file-permissions/
	* https://github.com/microsoft/WSL/issues/4200
	* https://blog.davidbollobas.hu/2022/09/19/mount-windows-folder-to-wsl-ubuntu/
	* https://learn.microsoft.com/en-us/windows/wsl/wsl2-mount-disk


### Prérequis

* 🪟 Windows 11
* 🪟 Oracle Virtualbox installé sur la partie HÔTE WINDOWS : Version 7.0.12 r159484 (Qt5.15.2)
	> ⚠️ PAS DANS LA PARTIE WSL !!!
* 🪟 Un répertoire dédié (avec assez d'espace disque) dans la partie HÔTE WINDOWS
	> Ici : `E:\Work` ; on y créera les sous-répertoires dédiés : `.\Devops\Vagrant\`
* 🐧 WSL 2 à jour (Installation non détaillée ici)
	```powershell
	wsl -v
	```
	```
	Version WSL : 2.4.13.0
	Version du noyau : 5.15.167.4-1
	Version WSLg : 1.0.65
	Version MSRDC : 1.2.5716
	Version direct3D : 1.611.1-81528511
	Version de DXCore : 10.0.26100.1-240331-1435.ge-release
	Version de Windows : 10.0.26100.3775
	```
	> Le `user:group` utilisé dans cette documentation est `homelab:homelab`

* 🐧 Packages à jour dans la partie WSL
	> Faire tous les `updates` / `upgrades` dans `apt`
* 🐧 Vagrant installé dans la partie WSL
	> ⚠️ PAS DANS LA PARTIE HÔTE WINDOWS
* 🐧 Ansible installé dans la partie WSL
	> ⚠️ PAS DANS LA PARTIE HÔTE WINDOWS

#### 🪟 Virtualbox

* Télécharger via : https://www.virtualbox.org/wiki/Downloads
* Installer (non détaillé ici)

#### 🐧 Dépendances diverses

> Je ne suis pas 100% sur qu'elles soient toutes 100% utiles

```bash
sudo apt install qemu qemu-kvm libvirt-clients libvirt-daemon-system virtinst bridge-utils
sudo systemctl enable libvirtd
sudo systemctl start libvirtd
sudo apt install -y ebtables
```


#### 🐧 Vagrant

* Suivre les instructions à cette adresse : https://developer.hashicorp.com/vagrant/install
	```bash
	wget -O - https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
	echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
	sudo apt update && sudo apt install vagrant
	```

* Installer le plugin WSL2
	```bash
	vagrant plugin install virtualbox_WSL2
	```

#### 🐧 Ansible

	```bash
	sudo apt-add-repository -y ppa:ansible/ansible
	sudo apt-get update
	sudo apt-get install -y ansible
	```


### Configuration

* 🐧 Mettre à jour la configuration par défaut de WSL
	```bash
	sudo vim /etc/wsl.conf
	```
	```
	[boot]
	systemd=true
	[automount]
	enabled = true
	mountFsTab = true
	```

* 🐧 Ajouter un point de montage dans la `fstab`, pour le répertoire de travail
	```bash
	sudo vim /etc/fstab
	```
	```
	E:\Work /home/homelab/work drvfs metadata,rw,noatime,uid=1000,gid=1000,umask=22,fmask=111 0 0
	```

* 🐧 Ajouter à la fin du `~/.bashrc` :
	```bash
	## For Vagrant
	export VAGRANT_WSL_ENABLE_WINDOWS_ACCESS="1"
	export PATH="$PATH:/mnt/c/Program Files/Oracle/VirtualBox"
	export VAGRANT_USER_DIR_E="/home/homelab/work/Devops/Vagrant/"
	export VAGRANT_WSL_WINDOWS_ACCESS_USER_HOME_PATH=${VAGRANT_USER_DIR_E}

	if [[ "$(umask)" = "0000" ]]; then
	  umask 0022
	fi
	```

* 🪟 Arrêter puis relancer WSL (depuis Powershell)
	```powershell
	wsl.exe --shutdown
	wsl.exe
	```

### 🐧 Création d'une VM de test avec un playbook minimal

* Création du playbook
	```bash
	cd ~/work/Devops/Vagrant
	vim playbook.yml
	```
	```yaml
	---
	- hosts: all
	  become: yes

	  tasks:
	  - name: Ensure chrony (for time synchronization) is installed.
		dnf:
		  name: chrony
		  state: present

	  - name: Ensure chrony is running.
		service:
		  name: chronyd
		  state: started
		  enabled: yes
	```

* Création de la VM
	```bash
	vagrant init geerlingguy/rockylinux8
	```
	```
	A `Vagrantfile` has been placed in this directory. You are now
	ready to `vagrant up` your first virtual environment! Please read
	the comments in the Vagrantfile as well as documentation on
	`vagrantup.com` for more information on using Vagrant.
	```

* Redéfinition du Vagrantfile pour y inclure le provisioning
	```bash
	vim Vagrantfile
	```
	```
	# -*- mode: ruby -*-
	# vi: set ft=ruby :
	Vagrant.configure("2") do |config|
	  config.vm.box = "geerlingguy/rockylinux8"
	  # Provisioning configuration for Ansible.
	  config.vm.provision "ansible" do |ansible|
		ansible.playbook = "playbook.yml"
	  end
	end	
	```

* Lancement et provisioning de la VM (elle se récupère automatiquement)
	```bash
	vagrant up
	```
	```
	Bringing machine 'default' up with 'virtualbox' provider...
	==> default: Importing base box 'geerlingguy/rockylinux8'...
	==> default: Matching MAC address for NAT networking...
	==> default: Checking if box 'geerlingguy/rockylinux8' version '1.0.1' is up to date...
	==> default: Setting the name of the VM: Vagrant_default_1745974859003_86420
	==> default: Clearing any previously set network interfaces...
	==> default: Preparing network interfaces based on configuration...
		default: Adapter 1: nat
	==> default: Forwarding ports...
		default: 22 (guest) => 2222 (host) (adapter 1)
		default: 22 (guest) => 2222 (host) (adapter 1)
	==> default: Booting VM...
	==> default: Waiting for machine to boot. This may take a few minutes...
		default: SSH address: 172.31.96.1:2222
		default: SSH username: vagrant
		default: SSH auth method: private key
		default:
		default: Vagrant insecure key detected. Vagrant will automatically replace
		default: this with a newly generated keypair for better security.
		default:
		default: Inserting generated public key within guest...
		default: Removing insecure key from the guest if it's present...
		default: Key inserted! Disconnecting and reconnecting using new SSH key...
	==> default: Machine booted and ready!
	==> default: Checking for guest additions in VM...
		default: The guest additions on this VM do not match the installed version of
		default: VirtualBox! In most cases this is fine, but in rare cases it can
		default: prevent things such as shared folders from working properly. If you see
		default: shared folder errors, please make sure the guest additions within the
		default: virtual machine match the version of VirtualBox you have installed on
		default: your host and reload your VM.
		default:
		default: Guest Additions Version: 6.1.32
		default: VirtualBox Version: 7.0
	==> default: Mounting shared folders...
		default: /home/homelab/work/Devops/Vagrant => /vagrant
	==> default: Running provisioner: ansible...
	Vagrant gathered an unknown Ansible version:


	and falls back on the compatibility mode '1.8'.

	Alternatively, the compatibility mode can be specified in your Vagrantfile:
	https://www.vagrantup.com/docs/provisioning/ansible_common.html#compatibility_mode

		default: Running ansible-playbook...

	PLAY [all] *********************************************************************

	TASK [Gathering Facts] *********************************************************
	[DEPRECATION WARNING]: Distribution centos 8.7 on host default should use
	/usr/libexec/platform-python, but is using /usr/bin/python for backward
	compatibility with prior Ansible releases. A future Ansible release will
	default to using the discovered platform python for this host. See https://docs
	.ansible.com/ansible/2.10/reference_appendices/interpreter_discovery.html for
	more information. This feature will be removed in version 2.12. Deprecation
	warnings can be disabled by setting deprecation_warnings=False in ansible.cfg.
	ok: [default]

	TASK [Ensure chrony (for time synchronization) is installed.] ******************
	ok: [default]

	TASK [Ensure chrony is running.] ***********************************************
	ok: [default]

	PLAY RECAP *********************************************************************
	default                    : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
	```

* Vérification des répertoires
	```bash
	ls -l
	```
	```
	drwxr-xr-x 1 homelab homelab 4096 Apr 30 03:11 .vagrant/
	drwxr-xr-x 1 homelab homelab 4096 Apr 30 03:11 .vagrant.d/
	-rw-r--r-- 1 homelab homelab 3397 Apr 30 03:11 Vagrantfile
	-rw------- 1 homelab homelab  266 Apr 30 00:56 playbook.yml
	```
	```bash
	ls -l .vagrant/machines/default/virtualbox/private_key
	-rw------- 1 homelab homelab 400 Apr 30 03:13 .vagrant/machines/default/virtualbox/private_key
	```

### Erreurs rencontrées pendant la création de cette documentation

```
The private key to connect to this box via SSH has invalid permissions
set on it. The permissions of the private key should be set to 0600, otherwise SSH will
ignore the key. Vagrant tried to do this automatically for you but failed. Please set the
permissions on the following file to 0600 and then try running this command again:

/mnt/e/Work/Devops/Vagrant/.vagrant/machines/default/virtualbox/private_key
```
> Cause initiale : impossible de modifier les permissions des fichiers dans le répertoire de travail (et masque 0000 par défaut)
>
> Cause réelle : répertoire de travail appartenant à un FS monté sans metadata et sans umask/fmask => permissions Windows réelles appliquées
>
> Solution (erronée) : définition des options metadata et umask/fmask dans les paramètres de l'automount (config globale WSL)
>
> Solution réelle : voir erreur suivante

```
Permission denied - /mnt/c/Program Files/Oracle/VirtualBox/VBoxManage.exe
```
> Cause : disques Windows montés dans WSL avec metadata et umask/fmask
>
> Solution : Montage d'un répertoire spécifique via fstab pour le répertoire de travail



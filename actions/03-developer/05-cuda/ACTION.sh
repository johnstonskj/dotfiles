if [[ $ACTION = install ]] ; then
	if [[ $OSSYS = macos ]] ; then
	    log-warning "CUDA unsupported under MacOS"
	else
	    log-debug "+++ graphics drivers"
	    local NVVER=`nvidia-smi |grep Version |awk '{ print $6 }'`
	    if [ $NVVER  != "418.43" ]; then
			run_command curl -o $DOWNLOADS/nvidia_linux.run "http://us.download.nvidia.com/XFree86/Linux-x86_64/418.43/NVIDIA-Linux-x86_64-418.43.run"
			run_command sudo sh nvidia_linux.run
			log-debug "+++ turning off Nouveau X drivers"
			run_command sudo bash -c "echo blacklist nouveau > /etc/modprobe.d/blacklist-nvidia-nouveau.conf"
			run_command sudo bash -c "echo options nouveau modeset=0 >> /etc/modprobe.d/blacklist-nvidia-nouveau.conf"
			log-debug "!!! leaving $DOWNLOADS/nvidia_linux.run"
	    fi
	    echo_instruction "reboot now for driver update"
	    
	    log-debug "+++ CUDA programming support..."
	    run_command curl -o $DOWNLOADS/cuda_linux.run "https://developer.nvidia.com/compute/cuda/10.1/Prod/local_installers/cuda_10.1.105_418.39_linux.run"
	    run_command sudo sh $DOWNLOADS/cuda_linux.run
	    run_command mkdir -p $DEVHOME/cuda
	    run_command cuda-install-samples-10.1.sh $DEVHOME/development/cuda/
	    log-debug "!!! leaving $DOWNLOADS/cuda_linux.run"
	fi
fi

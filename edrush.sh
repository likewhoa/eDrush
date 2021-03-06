#!/bin/bash -x

modlist=../.drushpkgs # module list from running 'edrush foobar foo ...'

# Prompt user to enable module(s)
drush_en() {
echo "Would you like to load ${i} now? (y/n):"; read answer
echo "If there are other extra modules that you like to load enter
them now seperated by space"; read extra_mods

if [[ ${answer} =~ [Yy]|[Ee][Ss] ]]; then
        drush -y en ${i} ${extra_mods}
fi
}

# Making sure we have a module list file.
[ ! -e ../.drushpkgs ] && touch ../.drushpkgs

# Main loop
for i in $@; do
        # Find the -dev if not then just download the top release version.
        ver=$(drush rl $i | grep dev | head -n1 | awk '{print$2}')

	# Validate variable
        if [ $ver ]; then
               	# Reinstall if old
               	if [ $(grep -w $i-$ver $modlist 2>/dev/null) ]; then
                       	echo "$(grep -w $i-$ver $modlist) found, updating."
                       	drush -y dl $(grep -w $i-$ver $modlist)
               	else
                       	echo "Installing $i-$ver"
                       	drush dl $i-$ver && echo $i-$ver>>$modlist
                       	drush_en
               	fi
        else
               	# Check if versioned
                if [[ $i =~ '${i}-*' ]]; then
                       	echo "Installing $i"
                       	drush dl $i && echo $i-$ver>>$modlist
                       	drush_en
               	elif [ $(grep -w $i $modlist 2>/dev/null) ]; then
                       	echo "$i found, updating."
                       	drush dl $i
               	else
                       	# No -dev copy found,. sniff sniff
                        ver=$(drush rl $i | sed -n 2p | awk '{print$2}')
                       	echo "Installing $i-$ver"
                       	drush dl $i-$ver && echo $i-$ver>>$modlist
                       	drush_en
               	fi
        fi
done

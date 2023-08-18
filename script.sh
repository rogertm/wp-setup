#!/bin/bash

colour_red=$'\e[1;31m'
colour_green=$'\e[1;32m'
colour_blue=$'\e[1;34m'
colour_end=$'\e[0m'

echo "========================================"
echo "WordPress Setup Installer"
echo "========================================"

wp_check=$(wp --version)

if [[ $wp_check == *"command not found" ]]; then
	echo "${colour_red}Unable to run WP CLI - Please ensure this is installed prior to using WP-Setup${colour_end}"
	exit
else
	read -p "Site Name: " sitename
	read -p "Site URL: " siteurl
	read -p "Admin User Name: " adminusername
	read -p "Admin Email: " adminemail
	read -p "Admin Password: " adminpassword
	read -p "Database Name: " dbname
	read -p "Database Tables Prefix: " dbprefix
	read -p "Database Username: " dbuser
	read -p "Database password: " dbpass
	read -p "Active Debug mode? [y/n]: " debug
	read -p "Ready to run the installer? [y/n]: " run

	if [ "$run" != "y" ]; then
		exit
	else
	echo ""
	echo "Starting install using $wp_check"

	{
		wp core download
	} &> /dev/null

	echo "Wordpress downloaded successfully"

	{
		wp core config --dbname=$dbname --dbuser=$dbuser --dbpass=$dbpass --dbprefix=$dbprefix

		wp db drop --yes
		wp db create
		wp core install --url="$siteurl" --title="$sitename" --admin_user="$adminusername" --admin_password="$adminpassword" --admin_email="$adminemail"
	} &> /dev/null

	echo "WordPress installed successfully"

	{
		# Deleting all pages and posts end empty trash can
		wp post delete $(wp post list --post_type='page' --format=ids)
		wp post delete $(wp post list --post_type='post' --format=ids)
		wp post delete $(wp post list --post_status=trash --format=ids)
	} &> /dev/null

	if [ "$debug" == 'y' ]; then
		echo "Setting up the Debug mode"

		{
			# Discourage search engines from indexing this site
			wp option update blog_public 0

			# Setting debug mode
			wp config set WP_DEBUG true --raw
			wp config set SAVEQUERIES true --raw
			wp config set SCRIPT_DEBUG true --raw
			wp config set WP_DEBUG_DISPLAY true --raw
			wp config set WP_DEBUG_LOG true --raw

		} &> /dev/null

		echo "Installing plugins for development environment"

		{
			# Install development plugins
			wp plugin install query-monitor debug-bar --activate
		} &> /dev/null
	fi

	echo "Removing useless plugins"

	{
		wp plugin delete hello
	} &> /dev/null

	echo "WordPress configuration completed"

	echo ""
	echo "========================================================================="
	echo "Installation is complete. Your username & password are listed below."
	echo ""
	echo "Username: ${colour_green}$adminusername${colour_end}"
	echo "Password: ${colour_green}$adminpassword${colour_end}"
	echo ""
	echo "========================================================================="
	fi
fi

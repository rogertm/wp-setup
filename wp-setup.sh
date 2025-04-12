#!/bin/bash

colour_red=$(tput setaf 1)
colour_green=$(tput setaf 2)
colour_blue=$(tput setaf 4)
colour_end=$(tput sgr0)

echo "========================================"
echo "WordPress Setup Installer"
echo "========================================"

if ! command -v wp &> /dev/null 2>&1; then
    echo "${colour_red}WP CLI is not installed or not in PATH. Please install it before running this script.${colour_end}"
    exit 1
fi

while true; do
    read -p "Site Name: " sitename
    if [ -z "$sitename" ]; then
        echo "Site Name cannot be empty"
        continue
    fi
    break
done

url_regex="^(http|https)://((localhost)|([0-9]{1,3}(\.[0-9]{1,3}){3})|([a-zA-Z0-9.-]+\.[a-zA-Z]{2,}))(/.*)?$"
while true; do
    read -p "Site URL: " siteurl
    if [ -z "$siteurl" ]; then
        echo "Site URL cannot be empty"
        continue
    fi
    if [[ $siteurl =~ $url_regex ]]; then
        break
    else
        echo "Invalid URL. Please enter a URL in the correct format (e.g., https://example.com or http://localhost)."
    fi
done

while true; do
    read -p "Admin User Name: " adminusername
    if [ -z "$adminusername" ]; then
        echo "Admin User Name cannot be empty"
        continue
    fi
    break
done

email_regex="^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$"
while true; do
    read -p "Admin Email: " adminemail
    if [ -z "$adminemail" ]; then
        echo "Admin Email cannot be empty"
        continue
    fi
    if [[ $adminemail =~ $email_regex ]]; then
        break
    else
        echo "Invalid email. Please enter an email address in the correct format (e.g., user@domain.com)."
    fi
done

while true; do
    read -s -p "Admin Password: " adminpassword
    echo ""
    read -s -p "Confirm Admin Password: " adminpassword_confirm
    echo ""
    if [ -z "$adminpassword" ]; then
        echo "Password cannot be empty. Please try again."
    elif [ "$adminpassword" = "$adminpassword_confirm" ]; then
        break
    else
        echo "Passwords do not match. Please try again."
    fi
done

while true; do
    read -p "Database Name: " dbname
    if [ -z "$dbname" ]; then
        echo "Database Name cannot be empty"
        continue
    fi
    break
done

dbprefix_regex="^[a-zA-Z_][a-zA-Z0-9_]*$"
while true; do
    read -p "Database Tables Prefix: " dbprefix
    if [ -z "$dbprefix" ]; then
        echo "Database Tables Prefix cannot be empty"
        continue
    fi
    if [[ $dbprefix =~ $dbprefix_regex ]]; then
        break
    else
        echo "Invalid prefix. It must start with a letter or underscore and contain only alphanumeric characters or underscores."
    fi
done

while true; do
    read -p "Database Username: " dbuser
    if [ -z "$dbuser" ]; then
        echo "Database Username cannot be empty"
        continue
    fi
    break
done

while true; do
    read -s -p "Database Password: " dbpass
    echo ""
    read -s -p "Confirm Database Password: " dbpass_confirm
    echo ""
    if [ -z "$dbpass" ]; then
        echo "Password cannot be empty. Please try again."
    elif [ "$dbpass" = "$dbpass_confirm" ]; then
        break
    else
        echo "Passwords do not match. Please try again."
    fi
done

while true; do
    read -p "Active Debug mode? [y/n]: " debug
    debug=$(echo "$debug" | tr '[:upper:]' '[:lower:]')
    if [[ "$debug" == "y" || "$debug" == "n" ]]; then
        break
    else
        echo "Invalid input. Please enter 'y' or 'n'."
    fi
done

while true; do
    read -p "Ready to run the installer? [y/n]: " run
    run=$(echo "$run" | tr '[:upper:]' '[:lower:]')
    if [[ "$run" == "y" || "$run" == "n" ]]; then
        break
    else
        echo "Invalid input. Please enter 'y' or 'n'."
    fi
done
if [ "$run" != "y" ]; then
    exit 0
fi

echo ""
echo "Starting install using $(wp --version)"

if ! wp core download; then
    echo "${colour_red}Failed to download WordPress${colour_end}"
    exit 1
fi

echo "WordPress downloaded successfully"

if ! wp core config --dbname="$dbname" --dbuser="$dbuser" --dbpass="$dbpass" --dbprefix="$dbprefix"; then
    echo "${colour_red}Failed to configure WordPress${colour_end}"
    exit 1
fi

echo "Setting up the database..."
if wp db check; then
    echo "Database exists. Dropping it..."
    if ! wp db drop --yes; then
        echo "${colour_red}Failed to drop the existing database${colour_end}"
        exit 1
    fi
else
    echo "Database does not exist. Creating a new one..."
fi

if ! wp db create; then
    echo "${colour_red}Failed to create the database${colour_end}"
    exit 1
fi

if ! wp core install --url="$siteurl" --title="$sitename" --admin_user="$adminusername" --admin_password="$adminpassword" --admin_email="$adminemail"; then
    echo "${colour_red}Failed to install WordPress${colour_end}"
    exit 1
fi

echo "WordPress installed successfully"

while true; do
    read -p "Delete all default posts/pages? [y/n]: " delete_posts
    delete_posts=$(echo "$delete_posts" | tr '[:upper:]' '[:lower:]')
    if [[ "$delete_posts" == "y" || "$delete_posts" == "n" ]]; then
        break
    else
        echo "Invalid input. Please enter 'y' or 'n'."
    fi
done
if [ "$delete_posts" == 'y' ]; then
    if ! wp post delete $(wp post list --post_type='page' --format=ids); then
        echo "${colour_red}Failed to delete pages${colour_end}"
    fi

    if ! wp post delete $(wp post list --post_type='post' --format=ids); then
        echo "${colour_red}Failed to delete posts${colour_end}"
    fi

    if ! wp post delete $(wp post list --post_status=trash --format=ids); then
        echo "${colour_red}Failed to delete trashed posts${colour_end}"
    fi
fi

if [ "$debug" == 'y' ]; then
    echo "Setting up the Debug mode"

    if ! wp option update blog_public 0; then
        echo "${colour_red}Failed to update blog_public option${colour_end}"
    fi

    if ! {
        wp config set WP_DEBUG true --raw &&
        wp config set SAVEQUERIES true --raw &&
        wp config set SCRIPT_DEBUG true --raw &&
        wp config set WP_DEBUG_DISPLAY true --raw &&
        wp config set WP_DEBUG_LOG true --raw
    }; then
        echo "${colour_red}Failed to set debug options${colour_end}"
    fi

    echo "Installing plugins for development environment"

    if ! wp plugin install query-monitor --activate; then
        echo "${colour_red}Failed to install Query Monitor${colour_end}"
    fi

    if ! wp plugin install debug-bar --activate; then
        echo "${colour_red}Failed to install Debug Bar${colour_end}"
    fi
fi

echo "Removing useless plugins"

if ! wp plugin delete hello; then
    echo "${colour_red}Failed to delete Hello Dolly plugin${colour_end}"
fi

echo "Updating plugins"

if ! wp plugin update --all; then
    echo "${colour_red}Failed to update plugins${colour_end}"
fi

echo "Updating themes"

if ! wp theme update --all; then
    echo "${colour_red}Failed to update themes${colour_end}"
fi

echo ""
echo "WordPress configuration completed"
echo ""
echo "========================================================================="
echo "Installation is complete."
echo ""
echo "Site URL: ${colour_green}$siteurl${colour_end}"
echo "Username: ${colour_green}$adminusername${colour_end}"
echo "Password: ${colour_green}[HIDDEN FOR SECURITY]${colour_end}"
echo ""
echo "========================================================================="

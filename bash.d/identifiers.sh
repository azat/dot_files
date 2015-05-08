# Different identifiers

export EMAIL=$(git config user.email)
export EMAIL_ADDRESS="$EMAIL"

export NAME=$(git config user.name)
export CHANGE_LOG_NAME=$NAME
export DEBFULLNAME="$NAME"
export DEBUILD_DPKG_BUILDPACKAGE_OPTS="-k'$NAME <$EMAIL>'"

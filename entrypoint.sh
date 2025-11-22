#!/bin/sh
set -e

echo "--- START CONTAINER DEBUG ---"
echo "Running as user: $(whoami)"
echo "Working directory: $(pwd)"

echo ""
echo "Listing files in /var/opentripplanner:"
ls -la /var/opentripplanner

echo ""
echo "Final command to be executed:"
CMD="java $JAVA_OPTS -cp @/app/jib-classpath-file @/app/jib-main-class-file --build --serve /var/opentripplanner"
echo "$CMD"
echo "--- END CONTAINER DEBUG ---"

# Execute the command
exec sh -c "$CMD"

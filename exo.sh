#!/bin/bash

# Exoskeleton System Management Script
# Usage: ./exo.sh [build|launch]

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

case "$1" in
    build)
        echo "Building exoskeleton system..."
        colcon build --symlink-install
        echo ""
        echo "Build complete! Run 'source install/setup.bash' or restart terminal."
        ;;

    launch)
        echo "Launching exoskeleton system..."
        source install/setup.bash
        ros2 launch exo_bringup exo_system.launch.py
        ;;

    clean)
        echo "Cleaning build artifacts..."
        rm -rf build/ install/ log/
        echo "Clean complete!"
        ;;

    *)
        echo "Usage: $0 {build|launch|clean}"
        echo ""
        echo "Commands:"
        echo "  build   - Build all packages with colcon"
        echo "  launch  - Launch the complete exoskeleton system"
        echo "  clean   - Remove build/, install/, and log/ directories"
        exit 1
        ;;
esac

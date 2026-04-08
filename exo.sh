#!/bin/bash

# Exoskeleton System Management Script
# Usage: ./exo.sh [build|launch|clean|log]

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

LOG_BASE="${SCRIPT_DIR}/log"

case "$1" in
    build)
        echo "Building exoskeleton system..."
        colcon build --symlink-install
        echo ""
        echo "Build complete! Run 'source install/setup.bash' or restart terminal."
        ;;

    launch)
        # 生成带时间戳的日志目录
        TIMESTAMP=$(date +%Y%m%d_%H%M%S)
        export ROS_LOG_DIR="${LOG_BASE}/ros_${TIMESTAMP}"
        mkdir -p "$ROS_LOG_DIR"

        source install/setup.bash

        echo "============================================"
        echo " EXO System Launch"
        echo " Logs → ${ROS_LOG_DIR}"
        echo " Press Ctrl+C to stop all nodes"
        echo "============================================"

        # 转发额外参数，例如: ./exo.sh launch k_factor:=0.5
        shift
        ros2 launch exo_bringup exo_system.launch.py "$@"
        ;;

    clean)
        echo "Cleaning build artifacts..."
        rm -rf build/ install/
        echo "Clean complete!"
        ;;

    log)
        # 查看/管理日志
        case "$2" in
            list)
                echo "Recent ROS log sessions:"
                ls -dt "${LOG_BASE}"/ros_* 2>/dev/null | head -10 || echo "  (none)"
                ;;
            latest)
                LATEST=$(ls -dt "${LOG_BASE}"/ros_* 2>/dev/null | head -1)
                if [ -n "$LATEST" ]; then
                    echo "Latest: $LATEST"
                    ls -lh "$LATEST"/
                else
                    echo "No log sessions found."
                fi
                ;;
            clean)
                echo "Removing all ROS log sessions..."
                rm -rf "${LOG_BASE}"/ros_*
                echo "Log clean complete!"
                ;;
            *)
                echo "Usage: $0 log {list|latest|clean}"
                ;;
        esac
        ;;

    help|*)
        echo "Exoskeleton System Management Script"
        echo ""
        echo "Usage: $0 <command> [options]"
        echo ""
        echo "Commands:"
        echo "  build              Build all packages (colcon build --symlink-install)"
        echo "  launch [args...]   Launch the exo system, logs to log/ros_<timestamp>/"
        echo "                       e.g. $0 launch k_factor:=0.5 source_select:=tcn"
        echo "  clean              Remove build/ and install/ directories"
        echo "  log list           List recent ROS log sessions"
        echo "  log latest         Show files in the latest log session"
        echo "  log clean          Remove all ROS log sessions"
        echo "  help               Show this help message"
        [ "$1" != "help" ] && exit 1 || exit 0
        ;;
esac

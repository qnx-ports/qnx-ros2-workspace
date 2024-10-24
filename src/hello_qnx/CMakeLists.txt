cmake_minimum_required(VERSION 3.5)

project(hello_qnx)

find_package(ament_cmake REQUIRED)
find_package(rclcpp REQUIRED)

add_executable(hello_qnx
    src/hello_qnx_main.cpp)

target_link_libraries(hello_qnx
    spdlog)

ament_target_dependencies(hello_qnx
    "rclcpp")

install(TARGETS
    hello_qnx
    DESTINATION lib/${PROJECT_NAME})

ament_package()

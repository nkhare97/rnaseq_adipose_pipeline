nextflow.enable.dsl=2
process TEST_CONTAINER {
container 'ubuntu:22.04'
output:
path 'container_test.txt'
script:
"""
echo "Hello from inside the container" > container_test.txt
cat /etc/os-release >> container_test.txt
"""
}
workflow {
TEST_CONTAINER()
}

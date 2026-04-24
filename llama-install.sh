#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

echo "Starting Termux environment setup for llama-server (OpenCL)..."

# 1. Request storage permissions
echo "Requesting storage access... Please click 'Allow' on your phone screen if prompted."
termux-setup-storage
sleep 2

# 2. Update and upgrade Termux packages
echo "Updating package lists..."
pkg update -y
pkg upgrade -y

# 3. Install all required dependencies
echo "Installing compilers, Python, and OpenCL headers..."
pkg install git cmake clang python opencl-headers ocl-icd binutils -y

# 4. Clone the repository
echo "Cloning the repository..."
cd ~
git clone https://github.com/TheTom/llama-cpp-turboquant llama-cpp-turboquant

# 5. Compile with OpenCL support
echo "Compiling llama-server with OpenCL acceleration..."
cd ~/llama-cpp-turboquant
cmake -B build -DCMAKE_BUILD_TYPE=Release -DGGML_OPENCL=ON
cmake --build build --config Release -j8

# 6. Create the launch script with your optimized parameters
echo "Creating the start-llama.sh launch script..."
cd ~
cat << 'EOF' > start-llama.sh
#!/bin/bash
./llama-cpp-turboquant/build/bin/llama-server \
  -m /storage/emulated/0/Download/gemma-4-e4b-it-UD-Q8_K_XL.gguf \
  --host 0.0.0.0 --port 8080 \
  -c 8192 \
  -ctk turbo4 -ctv turbo4 \
  -t 4 \
  -ngl 99 \
  -nkvo \
  -np 1 \
  --chat-template gemma
EOF

# Make the launch script executable
chmod +x start-llama.sh

echo ""
echo "======================================================"
echo "Setup Complete!"
echo "Your server is compiled and ready."
echo "To launch the server anytime, just type:"
echo "./start-llama.sh"
echo "======================================================"
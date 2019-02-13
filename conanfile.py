from conans import ConanFile, CMake, tools, RunEnvironment
import pprint

class WebRtcConan(ConanFile):
	name = "conan-webrtc"
	
	version = tools.get_env("CONAN_FILE_VERSION", None)
	
	license = "Smoothwall Ltd"
	author = "Steve White <steve.white@smoothwall.com>"
	url = "https://github.com/Smoothwall/conan-webrtc"
	description = "Chromium WebRTC packaged as a conan C++ dependency"
	topics = ("webrtc")
	exports_sources = "out/webrtc-*", "out/package_name.txt"
	no_copy_source = True
	short_paths = True
	
	settings = "os", "compiler", "build_type", "arch"

	def package(self):
		if str(self.settings.build_type) == "debug":
			bin_src_type = "Debug"
		else:
			bin_src_type = "Release"
		
		print("version: " + self.version)
		print("build_type: " + bin_src_type)
				
		# input: 26639 webrtc-26624-1a1c52b-win-x64 -> output: webrtc-26624-1a1c52b-win-x64
		package_name = tools.load(self.source_folder + "/out/package_name.txt").rstrip().split(' ')[1] 
		
		src_root = self.source_folder + "/out/" + package_name
		lib_search_path = src_root + "/lib/x64/" + bin_src_type + "/"
		
		print("Process includes... " + src_root)
		
		self.copy("*.h", dst="include", src=src_root + "/include")
		self.copy("*.hpp", dst="include", src=src_root + "/include")
		self.copy("*.hxx", dst="include", src=src_root + "/include")
		
		print("Process libs, lib_search_path = " + lib_search_path)
		
		self.copy("*.lib", dst="lib", src=lib_search_path, keep_path=False)
		
	def package_info(self):
		self.cpp_info.libs = ["libwebrtc_full"]
		#if self.settings.os == "Windows":
		#	self.cpp_info.libdirs = ['bin']

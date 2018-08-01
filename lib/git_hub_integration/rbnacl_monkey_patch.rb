module RbNaCl
  # MonkeyPatch to detect libsodium because ffi won't do it for us
  module Libsodium
    class << self
      def lib_path
        "/usr/lib/x86_64-linux-gnu"
      end

      def detect_libsodium_on_heroku
        Dir.glob(File.join(lib_path, "libsodium*.so.*")).first
      end
    end
    if detect_libsodium_on_heroku.present?
      ::RBNACL_LIBSODIUM_GEM_LIB_PATH = detect_libsodium_on_heroku
    end
  end
end

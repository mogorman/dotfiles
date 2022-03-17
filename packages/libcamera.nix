{ stdenv
, fetchgit
, lib
, meson
, ninja
, pkg-config
, boost
, gnutls
, openssl
, libevent
, lttng-ust
, gst_all_1
, gtest
, graphviz
, doxygen
, python3
, python3Packages
, qtbase
, libGL
, wrapQtAppsHook
}:

stdenv.mkDerivation {
  pname = "libcamera";
  version = "unstable-2022-03-16";

  src = fetchgit {
    url = "https://git.libcamera.org/libcamera/libcamera.git";
    rev = "58faa4f360db826fecd620d1580457df85740a54";
    sha256 = "sha256-TIHRlDnIuncfI3NlN5ef0H8kKcwQDuGEgc1/AYSS8hQ=";
  };

  postPatch = ''
    patchShebangs utils/
  '';

  buildInputs = [
    # IPA and signing
    gnutls
    openssl
    boost

    # gstreamer integration
    gst_all_1.gstreamer
    gst_all_1.gst-plugins-base

    # cam integration
    libevent

    # lttng tracing
    lttng-ust
  ];

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    python3
    python3Packages.jinja2
    python3Packages.pyyaml
    python3Packages.ply
    python3Packages.sphinx
    gtest
    graphviz
    doxygen
    qtbase
    libGL
    wrapQtAppsHook
  ];

  propagatedBuildInputs = [ qtbase];

#  mesonFlags = [ "-Dv4l2=true" "-Dqcam=disabled" ];
  mesonFlags = [ "-Dpipelines=uvcvideo,vimc,ipu3" "-Dipas=vimc,ipu3" "-Dgstreamer=enabled" ];
  # Fixes error on a deprecated declaration
  NIX_CFLAGS_COMPILE = "-Wno-error=deprecated-declarations";

  meta = with lib; {
    description = "An open source camera stack and framework for Linux, Android, and ChromeOS";
    homepage = "https://libcamera.org";
    license = licenses.lgpl2Plus;
    maintainers = with maintainers; [ citadelcore ];
  };
}

{ lib, buildPythonApplication, fetchFromGitHub, python3, i2c-tools, }:

buildPythonApplication rec {
  pname = "asus-touchpad-numpad-driver";
  version = "unstable-2022-03-11";
  format = "other";

  src = fetchFromGitHub {
    owner = "mohamed-badaoui";
    repo = pname;
    rev = "a2bada610ebb3fc002fceb53ddf93bc799241867";
    sha256 = "sha256-qanPTmP2Sctq4ybiUFzIiADP2gZH8HhajBORUSIXb04=";
  };

  propagatedBuildInputs = with python3.pkgs; [
    libevdev
    evdev
    numpy
    inotify
    xlib
  ];

  installPhase = ''
    install -Dm744 asus_touchpad.py $out/bin/asus_touchpad.py
    install -Dm644 -t $out/bin/numpad_layouts numpad_layouts/*.py
  '';

  meta = with lib; {
    description =
      "Up-to-date feature-rich linux driver for NumberPad(2.0) on Asus laptops";
    homepage = "https://github.com/asus-linux-drivers/asus-touchpad-numpad-driver";
    license = licenses.gpl2;
    platforms = [ "x86_64-linux" ];
    maintainers = with maintainers; [ tiredofit ];
    mainProgram = "asus_touchpad.py";
  };
}

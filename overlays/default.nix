{inputs, ...}: {
  additions = final: _prev: import ../pkgs final.pkgs;

  modifications = final: prev: {
  };

  #stable-packages = final: _prev: {};
  #unstable-packages = final: _prev: {};
}
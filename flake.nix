{
  
  description = "A Nix library for generating Lisp S-expressions";
  
  inputs = {};
  
  outputs = { self } : {
    
    lib = import ./lib;
    
  };
  
}

This is how I was able to use "import std;" with GCC 15:

/!\ **The following command returns an error which should be ignored!**

```g++ -std=gnu++26 -fmodules -fsearch-include-path bits/std.cc```

```g++ -std=gnu++26 -fmodules day4.cpp```

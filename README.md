# DASM
Or the Dumb Assembly Socket Manager, is a very small HTTP server made in x86 64-bit assembly for Linux systems.
The reason Why it's dumb is because it only returns one message and has very basic error handeling.

It was disigned to be an example of how to make small assembly programs and to be used for further modifications to it's source code to make it a not so dumb assembly socket manager (NSDASM)

# Building

## Note

You will not be able to run this on windows or macOS, the assembly is simply not compatable with anything other than Linux.
If you want to try your luck with BSD or other Unix-like operating systems, be my guest.

1. You'll need to have nasm, make, and the GNU Binutils installed, specifically a version of GNU Binutils that has the strip command with the `--strip-section-headers` available. (like version 2.42.0)
2. Use git cone to clone the repository. `git clone https://github.com/Skeleton590/dasm.git`
3. Go to the project directory and run the make command.
```
cd dasm
make
```

Once you do all that you should have a executable called `a.out` in the project directory.

# Running and connecting to the server

Once you have the server built you can run it by running `a.out` in the project directory.
```
$ ./a.out
[Starting server]

[SERVER]: Listening for clients...
```

After that you can connect to it by going to `localhost:4050` or `127.0.0.1:4050` in your browser.

# Notes on feature requsets and issues

I don't feel like I can take on the responsibility of handling issues and debuging and such. also I code for fun so i'll add features and fix bugs if I find it fun to do.
At same time I don't want to leave people hanging if they want to know how to fix somthing with the program.

I'll try to be on GitHub to fix issues and stuff but don't expect them to be frequent or high in quality.
Also i'm new to GitHub so please forgive the sloppiness.

Thank you, enjoy!

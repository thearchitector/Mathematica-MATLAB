<img src="/tomatlab.svg" width="128">

# Mathematica-MATLAB
A Wolfram Language Package for converting Mathematica syntax to MATLAB code. It was originally created by Harri Ojanen, but has been updated and modified for functionality and clarity.

## Installation
Download `ToMatlab.wl` to somewhere permanent on your machine. You can download the file by clicking <a href="https://raw.githubusercontent.com/thearchitector/Mathematica-MATLAB/master/ToMatlab.wl" download>here</a>. It is recommended that the file be placed witihin the `Mathematica\Applications` folder in your OS application data directory. On Windows, it can be accessed by pressing **Windows + R**, and entering `%appdata%\Mathematica\Applications`.

To use the package, open any Wolfram Mathematica file. Navigate to `File -> Install...`. When the dialog box opens, select `Package` as the type of item to install. For its source, select `From File...`, navigate to wherever you downloaded the file, and choose it. Leave all the other options as their default values, and click `Ok`.

_NOTE: If you want to download a newer version of this package at a later date, you must follow all the above installation steps again. The packages do not update if you simply change the file._

## Usage
Usage of the package is very simple. In whatever Mathematica script you are editing, add

```
Needs["ToMatlab`"];
```

to its beginning. Run it. When you wish to convert an output to MATLAB syntax, simply add `// ToMatlab` to the end of the line. In all cases, variable names are preserved if originally symbolic. Non-unicode characters, such as greek letters, are converted to their character names. For example, `α` will become `alpha`.

A simple use-case might be the conversion of a parametric equation for a circle to MATLAB.

```
r[u_] = {R*Cos[u], R*Sin[u], 0};
r[u] // ToMatlab

--> [R.*cos(u), R.*sin(u), 0];
```

By default, line outputs are suppressed. You can pass translation options by calling the function standardly.

```
r[u_] = {A*Cos[u], B*Sin[u], 0};
ToMatlab[r[u], SuppressOutput -> False]

--> [A.*cos(u), B.*sin(u), 0]
```

On occasion, Mathematica lists may want to be converted to MATLAB column matrices. In this case, you pass set the `Transposed` option to output a correct column vector.

```
r[u_] = {A*Cos[u], A*Sin[u], B*u};
ToMatlab[r[u], Transposed -> True, SuppressOutput -> False]

--> [A.*cos(u); A.*sin(u); B.*u]
```

If you find that your program repeats the `Transposed` or `SuppressOutput`, you can also set the default options for `ToMatlab` with `SetOptions[ToMatlab, { Transposed -> True, SuppessOutput -> False }]`.

Currently, the only options supported are `Transposed` and `SuppressOutput`. If you have suggestions on additional configuration parameters, please submit an Issue or Pull Request.

_NOTE: When converting lists to matrices, MATLAB requires uniform dimensionality. In the context of our parametric equation, the last column must be of size `u` if `u` is a matrix. In this case, making the last entry `0*u` when in MATLAB will solve this problem. This applies to all columns or rows of any matrix. In the cases where a constant is output, it can be changed to a vector with the `ones` and `size` commands. If we wanted a column of dimensionality `u` and of value `k`, we could enter either `k*ones(size(1, u))` or `k*(u./u)`._

> This program was adapted for the lives of the students taking Quantatative Engineering Analysis at Olin College.
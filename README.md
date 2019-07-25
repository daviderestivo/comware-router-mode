# Comware Router Mode
An Emacs major mode for editing Comware routers and switches
configuration files.

# Introduction
Taking inspiration from Noufal Ibrahim and his
[cisco-router-mode](https://www.emacswiki.org/emacs/cisco-router-mode.el),
I decided to write a major mode for editing Comware routers and
switches configuration files. This mode is still in alpha version.
Please feel free to contribute in improving it.

# Installation
Download and copy comware-router mode into your `~/.emacs.d/lisp`
direcotry and add the following to your `init.el`.

```
;; Tell Emacs where is your personal elisp lib directory
(add-to-list 'load-path "~/.emacs.d/lisp/")

;; comware-router-mode
;; https://github.com/daviderestivo/comware-router-mode
(load-library "comware-router-mode")
```

# Keybindings
| Key  | Function                   |
| :--- | :---                       |
| C-j  | comware-router-indent-line |

# License
 This file is NOT part of GNU Emacs.

 This program is free software; you can redistribute it and/or
 modify it under the terms of the GNU General Public License
 as published by the Free Software Foundation; either version 3
 of the License, or (at your option) any later version.

 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.

# Contribution
Feel free to open an issue in case of questions or problems.
Contribution are always welcome.

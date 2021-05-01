# ntty
Neovim terminal manager that exceeds expectations.

## Installation
ntty requires sqlite and [sql.nvim](https://www.github.com/tami5/sql.nvim) to store keybindings. Follow
instructions at [sql.nvim](https://www.github.com/tami5/sql.nvim).

## Usage
### Open/find terminal
```
lua require('ntty.term').gotoTerminal(1)
```
### Switch back to non-terminal buffer
```
lua require('ntty.term').switch_back()
```
### Send job to terminal and store it in the db
```
lua require('ntty.term').sendCommand(3, 'npm run start\n')
```
### Call previous command called in directory or subdirectories.
```
lua require('ntty.term').sendCommand(3)
```

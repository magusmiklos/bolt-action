![image](https://github.com/user-attachments/assets/c1ac890d-67e8-4fb6-8dc3-1495ea4be82a)

## Bolt Action what is it used for?
This is a Neovim plugin used for quick, (blazingly-fast) navigation.

![image](https://github.com/user-attachments/assets/4be8bfe8-03e9-4407-aff5-f63db68e0263)

The idea is that you can create "bookmarks" in different files and then quickly jump to them.
Also, your bookmarks are saved in a file, so they don't disappear after exiting Vim (`:q!`).

## How to really use this thing
There are 9 slots that you can use for your bookmarks, numbered from 1 to 9.

- Save a bookmark by pressing `leader + b + s` followed by a number.
- Jump to a bookmark by pressing `leader + b +` the selected number.
- Delete a bookmark by overwriting it or by pressing `leader + b + d` followed by the selected number.

You can view existing bookmarks, navigate between them, or delete them using a "GUI" as well. To access this, press `leader + b + v`.

In the GUI:
- You can jump to a bookmark by moving the cursor to it and pressing Enter.
- Delete a bookmark by pressing `d`.
- Close the GUI by pressing `Esc`.

# use it with lazy

```lua
require('lazy').setup({
  {
    'magusmiklos/bolt-action',
    config = function()
      require('bolt-action').setup()
    end,
  },
})
```
# change the hot keys

```lua
require('lazy').setup({
  {
    'magusmiklos/bolt-action',
    config = function()
      require('bolt-action').setup({
        leader = vim.g.mapleader or ' ',
        add_prefix = 'bs',
        go_prefix = 'b',
        view_prefix = 'bv',
        delete_prefix = 'bd',
      })
    end,
  },
})
```

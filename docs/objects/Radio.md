Radios are objects where you can create endless entrys the user can click on a button and it opens a "list" where the user can choose a entry

Here is a example of how to create a standard radio:

````lua
local mainFrame = basalt.createFrame("myFirstFrame"):show()
local aRadio = mainFrame:addRadio("myFirstRadio"):show()
````

Here are all possible functions available for radios: <br>
Remember radio inherits from [object](https://github.com/NoryiE/basalt/wiki/Object):

## addItem
Adds a item to the radio

````lua
local mainFrame = basalt.createFrame("myFirstFrame"):show()
local aRadio = mainFrame:addRadio("myFirstRadio"):show()
aRadio:addItem("1. Entry",3,4)
aRadio:addItem("2. Entry",3,5,colors.yellow)
aRadio:addItem("3. Entry",3,6,colors.yellow,colors.green)
````
**parameters:** string text, number x, number y, number bgcolor, number fgcolor, any ... - (text is the displayed text, bgcolor and fgcolors the colors of background/text and args (...) is something dynamic, you wont see them but if you require some more information per item you can use that)<br>
**returns:** self<br>

## removeItem
Removes a item from the radio

````lua
local mainFrame = basalt.createFrame("myFirstFrame"):show()
local aRadio = mainFrame:addRadio("myFirstRadio"):show()
aRadio:addItem("1. Entry",3,4)
aRadio:addItem("2. Entry",3,5,colors.yellow)
aRadio:addItem("3. Entry",3,6,colors.yellow,colors.green)
aRadio:removeItem(2)
````
**parameters:** number index<br>
**returns:** self<br>

## editItem
Edits a item on the radio

````lua
local mainFrame = basalt.createFrame("myFirstFrame"):show()
local aRadio = mainFrame:addRadio("myFirstRadio"):show()
aRadio:addItem("1. Entry",3,4)
aRadio:addItem("2. Entry",3,5,colors.yellow)
aRadio:addItem("3. Entry",3,6,colors.yellow,colors.green)
aRadio:editItem(3,"3. Edited Entry",3,6,colors.yellow,colors.green)
````
**parameters:** number index, string text, number x, number y, number bgcolor, number fgcolor, any ...<br>
**returns:** self<br>

## setScrollable
Makes the radio scrollable

````lua
local mainFrame = basalt.createFrame("myFirstFrame"):show()
local aRadio = mainFrame:addRadio("myFirstRadio"):show()
aRadio:addItem("1. Entry",3,4)
aRadio:addItem("2. Entry",3,5,colors.yellow)
aRadio:addItem("3. Entry",3,6,colors.yellow,colors.green)
aRadio:setScrollable(true)
````
**parameters:** boolean isScrollable<br>
**returns:** self<br>

## selectItem
selects a item in the radio (same as a player would click on a item)

````lua
local mainFrame = basalt.createFrame("myFirstFrame"):show()
local aRadio = mainFrame:addRadio("myFirstRadio"):show()
aRadio:addItem("1. Entry",3,4)
aRadio:addItem("2. Entry",3,5,colors.yellow)
aRadio:addItem("3. Entry",3,6,colors.yellow,colors.green)
aRadio:selectItem(1)
````
**parameters:** number index<br>
**returns:** self<br>

## clear
clears the entire list (radio)

````lua
local mainFrame = basalt.createFrame("myFirstFrame"):show()
local aRadio = mainFrame:addRadio("myFirstRadio"):show()
aRadio:addItem("1. Entry",3,4)
aRadio:addItem("2. Entry",3,5,colors.yellow)
aRadio:addItem("3. Entry",3,6,colors.yellow,colors.green)
aRadio:clear()
````
**parameters:** -<br>
**returns:** self<br>

## getItemIndex
returns the item index of the currently selected item

````lua
local mainFrame = basalt.createFrame("myFirstFrame"):show()
local aRadio = mainFrame:addRadio("myFirstRadio"):show()
aRadio:addItem("1. Entry",3,4)
aRadio:addItem("2. Entry",3,5,colors.yellow)
aRadio:addItem("3. Entry",3,6,colors.yellow,colors.green)
aRadio:getItemIndex()
````
**parameters:** -<br>
**returns:** number index<br>

## setSelectedItem
Sets the background of the item which is currently selected

````lua
local mainFrame = basalt.createFrame("myFirstFrame"):show()
local aRadio = mainFrame:addRadio("myFirstRadio"):show()
aRadio:addItem("1. Entry",3,4)
aRadio:addItem("2. Entry",3,5,colors.yellow)
aRadio:addItem("3. Entry",3,6,colors.yellow,colors.green)
aRadio:setSelectedItem(colors.green, colors.blue)
````
**parameters:** number bgcolor, number fgcolor, boolean isActive (isActive means if different colors for selected item should be used)<br>
**returns:** self<br>
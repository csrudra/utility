# KeysToPad

Play with a keyboard and mouse where only a controller is accepted. KeysToPad makes your keyboard
and mouse appear to Windows as an Xbox 360 controller, with a shortcut to switch back to using the
PC normally.

**Built for and tested with Xbox Remote Play, playing GTA VI.** The Xbox app on the PC sees the
virtual controller as a real one, so the console receives your keys and mouse as controller input.
It should also work with anything else on a Windows PC that accepts an Xbox controller.

## Setting up (once)

1. Install the free **ViGEmBus** driver: download the setup program from
   <https://github.com/nefarius/ViGEmBus/releases/latest> and run it. This is what creates the
   virtual controller; KeysToPad cannot work without it.
2. Install the [.NET 9 SDK](https://dotnet.microsoft.com/download/dotnet/9.0) and build:

   ```
   dotnet publish -c Release -r win-x64 --self-contained false -o publish
   ```

3. Run `publish\KeysToPad.exe`. A controller icon appears beside the clock (grey = off, green = on).

## Using it

- **Ctrl+Alt+G** switches controller mode on and off. A high beep means on, a low beep means off.
  Clicking the icon does the same.
- While it is on, the mapped keys and the mouse are kept from Windows and sent to the controller.
  Keys that are not in the list (Alt+Tab, the Windows key and so on) still work.
- While it is off, the keyboard and mouse behave normally. The virtual controller stays plugged in
  but untouched.
- Closing KeysToPad (right-click the icon, Exit) unplugs the controller.

### With Xbox Remote Play

1. Start KeysToPad.
2. Open Remote Play in the Xbox app and connect to your console.
3. Click into the stream, then press Ctrl+Alt+G. Press it again whenever you need the PC back.
4. In the game's controller settings, raise the look and aim sensitivity to the maximum, and lower
   the dead zone and acceleration if the game offers them.

Default layout:

| Keyboard / mouse | Controller |
|---|---|
| W A S D | Left stick |
| Mouse | Right stick |
| Left click / Right click | RT / LT |
| Space, Left Ctrl or C, R, F | A, B, X, Y |
| Q / E | LB / RB |
| Left Shift / V or middle click | Left / right stick click |
| Tab / Esc / Home | Back (View) / Start (Menu) / Guide |
| Arrow keys or 1 2 3 4 | D-pad |
| Left Alt (hold) | Walk (left stick half way) |
| Back side button / forward side button / wheel | B / Y / Y |

## Changing the layout and the mouse feel

Right-click the icon and choose **Edit settings**. The file (`settings.json`, beside the program)
explains every setting. Saving it applies the change straight away, so you can tune with the game
running. If the file has a mistake, a message says what is wrong and the previous settings stay in use.

Tuning the mouse, in this order:

1. `sensitivity`: raise it until a normal hand movement turns as far as you expect.
2. `deadZone`: if tiny movements do nothing, raise it; if the aim creeps or feels floaty, lower it.
3. `curve`: if slow movements feel sluggish compared with fast ones, try 0.6 to 0.8.
4. Turn the game's own stick sensitivity up to its maximum and its aim acceleration and smoothing off.
   A stick has a top turning speed and the game decides it; KeysToPad cannot go faster than that.

## How the mouse becomes a stick

A mouse reports distance and a stick reports speed. KeysToPad keeps the mouse's movement as distance
still to be played; many times a second it pushes the stick in proportion to what is waiting and
takes that much off. Below the stick's top speed this follows your hand with a little smoothing.
Above it, the stick stays fully pushed until the kept distance (limited by `carryOverMs`) is used up,
so a fast flick still turns roughly as far as you moved.

## Things to know

- A game or app that runs as administrator only sees KeysToPad if KeysToPad also runs as administrator.
- A PC game that also listens to the mouse directly may still notice it moving while controller mode
  is on. Most simply follow the controller; a few flip their button prompts back and forth.
- Online games may treat a keyboard and mouse posing as a controller as cheating. Check the rules of
  the game you play; this was made for single-player use.
- Ctrl+Alt+Delete always works, whatever KeysToPad is doing.

## Checks

None of these opens a window. Each writes its result to the file you name.

```
publish\KeysToPad.exe --selftest out.txt   mapping maths, settings reader, which events are kept from Windows
publish\KeysToPad.exe --hooktest out.txt   the real keyboard and mouse watch (sends F23, F24 and a small mouse nudge; about a second)
publish\KeysToPad.exe --padtest  out.txt   the virtual controller, read back the way a game reads it
```

## Credits

Uses the [ViGEmBus](https://github.com/nefarius/ViGEmBus) driver and the Nefarius.ViGEm.Client
library by Nefarius.

KeysToPad is an independent project. It is not affiliated with or endorsed by Microsoft, Xbox or
Rockstar Games. Xbox and GTA are trade marks of their owners.

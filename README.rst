===================
My AwesomeWM config
===================

This is configuration for AwesomeWM 4.4 (or git if not released yet).

.. image:: https://raw.github.com/wiki/mireq/awesome-wm-config/desktop.png?v=2023-04-02
   :alt: AwesomeWM desktop

Install
-------

Run::

    git clone --recursive https://github.com/mireq/awesome-wm-config ~/.config/awesome
    cd ~/.config/awesome
    make

Keyboard shortcuts
------------------

.. image:: https://raw.github.com/wiki/mireq/awesome-wm-config/keys.png?v=2023-04-02
   :alt: Keyboard shortcuts

================
Special features
================

DPI change support
------------------

This config supports DPI change on fly using API call::

    echo "require('api').change_dpi(192)"|awesome-client

There is example bash script `available in this repostory <https://github.com/mireq/awesome-wm-config/blob/master/tools/set_dpi>`_.

Video demonstration:

.. image:: https://img.youtube.com/vi/GZSCcyE-hAE/maxresdefault.jpg
    :alt: Awesome WM - change DPI on fly
    :target: https://www.youtube.com/watch?v=GZSCcyE-hAE

Best values for dpi are 96-multipliers. Here is low DPI screenshot:

.. image:: https://raw.github.com/wiki/mireq/awesome-wm-config/desktop_96_dpi.png?v=2023-04-02
   :alt: AwesomeWM desktop with 96 DPI

Bidirectional volume control using pulseaudio API
-------------------------------------------------

This configuration uses own pulseaudio commandline tool to change volume. It is
useable with pulseaudio or pipewire audio server.

Awesome starts control application on background and volume changed are directly
sent to running process. If someone changes volume, change is automatically
applied to awesome without polling. No extra interrupts, no extra CPU usage, no
extra power needed.

Master source / sink is automatically updated, if you connect headphones for
example, this widget will automatically change volume on new master.

More informations in `separate repository <https://github.com/mireq/pulsectrl>`_.

.. image:: https://raw.github.com/wiki/mireq/pulsectrl/volume.gif?v=2023-04-02
   :alt: Volume widget

Udisk2 mount
------------

This configuration includes native highly customizable udisks2 mount widget.

More informations in `separate repository <https://github.com/mireq/awesome-udisks2-mount>`_.

.. image:: https://raw.github.com/wiki/mireq/awesome-udisks2-mount/automount.gif?v=2023-04-01
   :alt: Mount

Battery logging
---------------

To log battery history, just create empty `~/.battery_history` file. History
will be automatically collected on charging / discharging state. To display
history call `~/.config/awesome/tools/battery_history`

.. image:: https://raw.github.com/wiki/mireq/awesome-wm-config/battery.png?v=2023-04-02
   :alt: Battery history

Screen recording
----------------

This repository includes screen recording scripts with near zero CPU usage. To
enable recording, first add permissions to ffmpeg::

    setcap cap_sys_admin+ep `which ffmpeg`

Now it's possible to start recording using shortcut Mod + Alt + Shift + r (same
shortcut to stop). Video will be available in /dev/shm/video.mkv

To record cursor, composite manager should be started. Cursor is recorded using
`software-cursor application <https://github.com/mireq/software-cursor>`_.

Alt + Tab window switching
--------------------------

with slightly modified `cyclefocus script <https://github.com/blueyed/awesome-cyclefocus>`_.

.. image:: https://raw.github.com/wiki/mireq/awesome-wm-config/alt_tab.png?v=2023-04-02
   :alt: Alt + Tab

Run command
-----------

.. image:: https://raw.github.com/wiki/mireq/awesome-wm-config/run_command.png?v=2023-04-02
   :alt: Run command

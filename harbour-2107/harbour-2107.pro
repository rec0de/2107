# NOTICE:
#
# Application name defined in TARGET has a corresponding QML filename.
# If name defined in TARGET is changed, the following needs to be done
# to match new name:
#   - corresponding QML filename must be changed
#   - desktop icon filename must be changed
#   - desktop filename must be changed
#   - icon definition filename in desktop file must be changed
#   - translation filenames have to be changed

# The name of your application
TARGET = harbour-2107

CONFIG += sailfishapp
QT += dbus

SOURCES += src/harbour-2107.cpp

OTHER_FILES += qml/harbour-2107.qml \
    qml/cover/CoverPage.qml \
    qml/pages/FirstPage.qml \
    rpm/harbour-2107.changes.in \
    rpm/harbour-2107.spec \
    rpm/harbour-2107.yaml \
    harbour-2107.desktop \
    qml/components/dove.qml \
    qml/components/track.qml \
    qml/data.js \
    qml/pages/settings.qml \
    qml/pages/about.qml \
    qml/pages/stats.qml \
    qml/pages/console.qml

# to disable building translations every time, comment out the
# following CONFIG line
#CONFIG += sailfishapp_i18n
TRANSLATIONS += translations/harbour-2107-de.ts

HEADERS +=

RESOURCES +=


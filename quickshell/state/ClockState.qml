pragma Singleton
import QtQuick

QtObject {
  property bool clockVisible: true
  function toggle() {
      clockVisible = !clockVisible
  }
}

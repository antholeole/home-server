import app from "ags/gtk4/app"
import style from "./style.scss"
import Bar from "./widget/Bar"

app.start({
  css: style,
  main() {
    // biome-ignore lint/suspicious/noExplicitAny: idk what it is!
    (app as any).get_monitors().map(Bar)
  },
})

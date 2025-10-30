package main

import (
	"image/color"
	"log"

	"fyne.io/fyne/v2"
	"fyne.io/fyne/v2/app"
	"fyne.io/fyne/v2/canvas"
	"fyne.io/fyne/v2/container"
	"fyne.io/fyne/v2/theme"
	"fyne.io/fyne/v2/widget"

	"github.com/skip2/go-qrcode"

	_ "embed"
)

//go:embed static/256x256/jxbarcode.png
var ad []byte

func main() {
	app := app.New()
	win := app.NewWindow("Barcode Generator")

	ic := fyne.NewStaticResource("jxbarcode.png", ad)
	win.SetIcon(ic)

	in := widget.NewEntry()
	in.SetPlaceHolder("Enter text input")

	co := container.NewVBox()

	// Generate button
	su := widget.NewButton("Generate Barcode", func() {
		tx := in.Text
		if tx == "" {
			return
		}

		qr, err := qrcode.New(tx, qrcode.Medium)
		if err != nil {
			log.Println("QR generation failed:", err)
			return
		}
		qm := qr.Image(256)

		im := canvas.NewImageFromImage(qm)
		im.FillMode = canvas.ImageFillContain
		im.SetMinSize(fyne.NewSize(256, 256))

		co.Objects = []fyne.CanvasObject{im}
		co.Refresh()
	})

	cl := widget.NewButtonWithIcon("", theme.CancelIcon(), func() {
		in.SetText("")
		co.Objects = nil
		co.Refresh()
	})

	sp := canvas.NewRectangle(color.Transparent)
	sp.SetMinSize(fyne.NewSize(1, 20))

	win.SetContent(container.NewVBox(
		container.NewBorder(nil, nil, nil, cl, in),
		su,
		sp,
		co,
	))

	win.Resize(fyne.NewSize(400, 400))
	win.ShowAndRun()
}

package main

import (
	"fmt"
	"github.com/Dana-Team/gonvml"
)


func failedMsg(msg string, err error) {
	fmt.Printf("%s: %+v\n", msg, err)
}

func main() {
	gonvml.Init()
	defer gonvml.Shutdown()

	device, err := gonvml.NewDevice(0)
	if err != nil {
		failedMsg("NewDevice", err)
	} else {
		fmt.Println(device.UUID)
	}
}
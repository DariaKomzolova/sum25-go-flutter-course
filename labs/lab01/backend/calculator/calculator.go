package calculator

import (
	"errors"
	"fmt"
)

var ErrDivisionByZero = errors.New("division by zero")

// Add adds two float64 numbers
func Add(a, b float64) float64 {
	// TODO: Implement this function
	return 0
}

// Subtract subtracts b from a
func Subtract(a, b float64) float64 {
	// TODO: Implement this function
	return 0
}

// Multiply multiplies two float64 numbers
func Multiply(a, b float64) float64 {
	// TODO: Implement this function
	return 0
}

// Divide divides a by b, returns an error if b is zero
func Divide(a, b float64) (float64, error) {
	if b == 0 {
		return 0, ErrDivisionByZero
	}
	return a / b, nil
}

func StringToFloat(s string) (float64, error) {
	// TODO: Implement this function
	return 0, nil
}

func FloatToString(f float64, precision int) string {
	format := fmt.Sprintf("%%.%df", precision)
	return fmt.Sprintf(format, f)
}

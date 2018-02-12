GetInteger(ByRef @source, _offset = 0, _bIsSigned = false, _size = 4)

{

	local result



	Loop %_size%  ; Build the integer by adding up its bytes.

	{

		result += *(&@source + _offset + A_Index-1) << 8*(A_Index-1)

	}

	If (!_bIsSigned OR _size > 4 OR result < 0x80000000)

		Return result  ; Signed vs. unsigned doesn't matter in these cases.

	; Otherwise, convert the value (now known to be 32-bit & negative) to its signed counterpart:

	return -(0xFFFFFFFF - result + 1)

}
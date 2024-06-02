import pyperclip
from typing import Tuple


def write_method(name: str, inter: bool = False) -> Tuple[str, str]:
    inter_ext:str = inter and "Inter_" or ""
    internal_func:str = f"\nfunction SWEP:{inter_ext}{name}()\n"
    internal_func += "\t-- Use custom if we should\n"
    internal_func += f"\tif self.Use_Custom_{name} == true then\n"
    internal_func += f"\t\treturn self:Custom_{name}()\n"
    internal_func += "\tend\n"
    internal_func += "end\n"

    custom_func:str = f"\nSWEP.Use_Custom_{name} = false\n"
    custom_func += f"function SWEP:Custom_{name}()\n"
    custom_func += "end\n"

    return internal_func, custom_func

def clipboard_routine(inter_meth:str, cus_meth:str) -> None:
    pyperclip.copy(inter_meth)
    print("Copied internal. ")
    input("Enter to continue: ")

    pyperclip.copy(cus_meth)
    print("Copied custom. ")

if __name__ == "__main__":
    inter_meth, cus_meth = write_method(input("Method name: "), input("Use 'Inter_'? (y/n) ") == "y")

    with open("lua/weapons/weapon_zwb_base/sh_internal.lua", "a") as f:
        f.write(inter_meth)

    with open("lua/weapons/weapon_zwb_base/sh_changeable.lua", "a") as f:
        f.write(cus_meth)

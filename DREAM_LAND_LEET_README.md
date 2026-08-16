# ⚡ DREAM LAND ⚡
## DREAM C // THE LITTLE LANGUAGE UNDER THE FLOORBOARDS

```text
╔══════════════════════════════════════════════════════════════╗
║  DREAM LAND                                                 ║
║  tiny language // huge reach // no permission required      ║
║                                                              ║
║  Dream> _                                                    ║
╚══════════════════════════════════════════════════════════════╝
```

**Dream Land** is a tiny systems-programming environment built to keep the surface small while leaving the machine underneath almost completely exposed.

It can run as a native Windows environment or boot directly as a **UEFI application**. Inside Dream you can type source, compile it, run it, save it, emit bytecode, emit raw machine images, generate x86-64 COFF objects, call native APIs, inherit C libraries, and drop straight into raw x86-64 bytes.

The idea is simple:

> **few words // few layers // no artificial ceiling**

---

# 0x00 // WHAT DREAM IS

Dream is intentionally **not ISO C** and it is not trying to become another giant language.

Its job is to give you a very small set of primitives that can reach very far:

```text
Dream syntax
    ↓
DRM3 bytecode
    ↓
raw memory / native ABI
    ↓
C libraries
    ↓
x86-64 asm
    ↓
COFF / PE / EFI / drivers / kernels
    ↓
metal
```

The language stays tiny because the escape hatches are powerful.

---

# 0x01 // BOOT INTO DREAM

The UEFI build is already packaged as a Ventoy-friendly ISO.

```text
POWER ON
   ↓
UEFI
   ↓
VENTOY
   ↓
DreamLand-UEFI-4.0-Ventoy.iso
   ↓
BOOTX64.EFI
   ↓
Dream>
```

At the prompt:

```text
Dream> list
Dream> man asm
Dream> man metal
Dream> man greetz
Dream> edit
```

You are now typing code **before Windows or Linux has started**.

---

# 0x02 // FIRST DREAM PROGRAM

```c
println("WELCOME TO DREAMLAND");
halt;
```

Run it:

```text
Dream> run
```

Or immediately execute a little fragment:

```text
Dream> do println(6*7);
```

Result:

```text
42
```

---

# 0x03 // THE LANGUAGE IN ONE SCREEN

### Values

```c
var x = 42;
int y = 53;
ptr p = 0;
```

All three are intentionally 64-bit Dream cells.

A cell may mean:

```text
integer
pointer
handle
address
bitfield
function pointer
whatever you decide
```

### Output

```c
print("x = ", x);
println("hello");
putc(65);
```

### Control flow

```c
var x = 0;

loop:
println(x);
x = x + 1;
if x < 10 goto loop;

halt;
```

### Subroutines

```c
call hello;
halt;

hello:
println("dream");
return;
```

---

# 0x04 // MACROS WITHOUT BUILDING A PREPROCESSOR MONSTER

Dream has deliberately tiny compile-time macros:

```c
macro LIMIT = 8;
macro PORT = 0x3F8;
macro GREEN = "\e[92m";
```

Then:

```c
var x = LIMIT;
print(GREEN, "DREAM", "\e[0m");
```

Dream understands `\e` as byte `27`, so ANSI escape sequences work naturally in terminal/native output.

That is the whole philosophy:

> add one doorway, not another building.

---

# 0x05 // RAW MEMORY

Allocate memory:

```c
var p = alloc(64);
```

Write to it:

```c
poke8(p, 0x41);
poke16(p + 2, 0x4243);
poke32(p + 8, 0x12345678);
poke64(p + 16, 0x1122334455667788);
```

Read it:

```c
println(peek8(p));
println(peek64(p + 16));
```

Release it:

```c
free(p);
```

Dream assumes you know that arbitrary pointers are sharp objects.

---

# 0x06 // RAW X86-64

Dream can execute machine code directly:

```c
var answer = asm {
    B8 2A 00 00 00
    C3
};

println(answer);
```

Those bytes are:

```asm
mov eax, 42
ret
```

Result:

```text
42
```

There is no pretend assembly layer here. `asm { ... }` is the escape hatch where Dream syntax ends and processor bytes begin.

---

# 0x07 // NATIVE WINDOWS API

Resolve a native API:

```c
var box = api("user32.dll", "MessageBoxA");
```

Call it:

```c
native(box,
    0,
    "DREAM IS ALIVE",
    "DREAM LAND",
    0
);
```

The hosted Win64 bridge supports direct scalar/pointer calls with up to six arguments.

---

# 0x08 // INHERIT THE C CIVILIZATION

Dream does **not** duplicate fifty years of C.

It borrows it.

```c
cimport <stdio.h>;
cimport <string.h>;

extern c i32 puts(cstr);
extern c u64 strlen(cstr);

var n = strlen("bajillions");
puts("DREAM -> C");
println(n);
```

Native build:

```text
Dream> cbuild
```

Or with the standalone compiler:

```text
dreamcc-3.5.exe --cgen dream.dc dream_native.c
```

Then compile the generated bridge with GCC or Clang.

### Link a library

```c
link "-lz";
```

or:

```c
link "mylibrary.lib";
```

### Weird C API?

Do not pollute Dream.

Wrap it:

```c
c {
    static long long dream_printf(const char *fmt, long long x) {
        return printf(fmt, x);
    }
}

extern c i64 dream_printf(cstr, i64);
```

Dream inherits the library.
Dream does not inherit the clutter.

---

# 0x09 // EXPORT DREAM BACK TO C

Dream can expose a label as a C-callable symbol:

```c
export c dream_mul3;

var a0 = 0;
var result = 0;

goto main;

dream_mul3:
result = a0 * 3;
return;

main:
halt;
```

C arguments arrive in:

```text
a0 a1 a2 a3 a4 a5
```

Return through:

```text
result
```

So the bridge runs both ways.

---

# 0x0A // BUILD A RAW MACHINE IMAGE

Dream's `metal` mode turns raw assembler blocks and tiny binary directives into a flat image.

Example:

```text
asm {
    FA
    F4
    EB FD
}

align 16
byte 0x42
word 0x1234
dword 0x12345678
qword 0x123456789ABCDEF0
```

Emit it:

```text
Dream> metal
```

Output:

```text
dream.bin
```

For a boot-sector-style image:

```text
asm {
    FA
    F4
    EB FD
}

pad 510 00
word 0xAA55
```

Now Dream is manufacturing bytes, not merely "running a program."

---

# 0x0B // BUILD AN X86-64 COFF OBJECT

Dream can wrap a metal payload as a real x86-64 COFF object:

```text
Dream> obj
```

Output:

```text
dream.obj
```

The object exports:

```text
dream_entry
```

That gives Dream a clean rendezvous with normal linkers.

---

# 0x0C // MAKE A MINIMAL WINDOWS DRIVER

A Windows kernel driver is more than "some privileged machine code." It needs the Windows driver ABI, the correct PE subsystem, and—on normal modern systems—appropriate signing/loading policy.

Dream can already generate the **machine-code object** that enters that toolchain.

### 1. Write a microscopic DriverEntry stub

```text
asm {
    31 C0
    C3
}
```

That is:

```asm
xor eax, eax
ret
```

On x64 Windows, a successful `DriverEntry` returns `STATUS_SUCCESS`, which is zero.

### 2. Emit COFF

```text
Dream> obj
```

You now have:

```text
dream.obj
```

with:

```text
dream_entry
```

### 3. Link as a native driver image

With Microsoft's linker:

```text
link dream.obj /driver /subsystem:native /entry:dream_entry /machine:x64 /out:dream.sys
```

With LLD:

```text
lld-link dream.obj /driver /subsystem:native /entry:dream_entry /machine:x64 /out:dream.sys
```

Now you have a PE32+ `.sys` image.

### 4. Real driver work begins here

For an actual useful driver you still need the Windows kernel contracts your device requires: correct `DriverEntry` signature, driver/device objects, dispatch routines or KMDF/WDM infrastructure, kernel imports, unload behavior where appropriate, INF/package metadata when applicable, and Windows signing/loading requirements.

Dream gives you the **code-generation and object/link boundary**. The OS still gets to define its ABI.

That distinction matters.

---

# 0x0D // A DREAM DRIVER WITH C HELP

For nontrivial drivers, the clean path is often:

```text
Dream
   +
small C compatibility layer
   ↓
COFF objects
   ↓
WDK / linker
   ↓
.sys
```

Dream source can own the interesting machine logic while a microscopic C adapter supplies whatever Windows-specific declarations are annoying.

Conceptually:

```c
c {
    /* include the exact WDK headers required by the target */
}

/* Dream-facing wrappers stay small */
```

This is the same philosophy as CBridge everywhere else:

> **inherit the ecosystem; do not become the ecosystem.**

---

# 0x0E // MAKE BOOT CODE / A KERNEL SEED

Dream can emit raw machine images directly:

```text
Dream> metal
```

And Dream UEFI can itself boot before an operating system exists.

Inside UEFI Dream you can access firmware pointers:

```c
var st = api("uefi", "st");
var bs = api("uefi", "bs");
var rs = api("uefi", "rs");
```

Available UEFI gates include:

```text
st
bs
rs
conout
conin
clear
stall
attr
print
```

Example:

```c
var delay = api("uefi", "stall");
native(delay, 100000);
```

So the ladder becomes:

```text
UEFI
  ↓
Dream>
  ↓
Dream compiler
  ↓
raw memory
  ↓
firmware services
  ↓
asm {}
  ↓
x86-64
  ↓
hardware
```

A full Dream OS would continue from here by taking ownership of the things UEFI currently provides: memory-map transition, `ExitBootServices()`, interrupts, paging policy, timers, input/display/storage drivers, filesystems, and eventually scheduling if desired.

The important part is that the programming environment already exists **before** that transition.

---

# 0x0F // DREAM'S NATIVE OPERATORS

Alongside ordinary arithmetic/logic:

```text
+ - * / %
<< >>
& | ^ ~
! && ||
== != < <= > >=
```

Dream has a few intentionally strange operators:

```text
%%    WEAVE
?=    MATCH
<->   RESONANCE / XOR coupling
->>   FLOW through native function pointer
@>    MATERIALIZE 64-bit value at address
```

Example:

```c
value @> address;
```

means roughly:

```text
store this 64-bit value at this raw address
```

---

# 0x10 // COMMAND DECK

```text
list             all commands/topics
search TERM      find a topic
man TOPIC        tiny manual
man example      example program
man greetz       makers/support/links

edit             source editor
run              compile + run
build            emit dream.dvm
save             save dream.dc
load             load dream.dc
new              empty buffer
clear            HOME

metal            emit dream.bin
obj              emit dream.obj
cgen             emit dream_native.c
cbuild           native CBridge build

lines            line numbers
sparkle          tiny low-motion flair
calm             motion off
hud              telemetry toggle
```

---

# 0x11 // THE BUILD TARGETS

```text
                 DREAM SOURCE
                      │
       ┌──────────────┼──────────────┐
       │              │              │
      DRM3          CBRIDGE         METAL
       │              │              │
   dream.dvm    dream_native.c    dream.bin
       │              │              │
   dreamvm       GCC / Clang       machine
                      │
                   native EXE

                      +

                 DREAM SOURCE
                      │
                     OBJ
                      │
                  dream.obj
                      │
                     LLD
              ┌───────┼────────┐
              │       │        │
             PE      EFI      SYS
```

---

# 0x12 // THE RULE

Dream is not designed around having a command for every possible task.

It is designed around having enough primitives that you can **reach the thing that already knows how**.

If Dream does not know a library:

```text
CBridge
```

If Dream does not know an API:

```text
api() + native()
```

If Dream does not know a memory structure:

```text
peek / poke
```

If Dream does not know an instruction:

```text
asm {}
```

If Dream does not know a binary format:

```text
metal
```

If Dream needs a normal systems linker:

```text
obj
```

That is the language.

---

# 0x13 // GREETZ

```text
MADE BY LUMINOSITY + GPTEUS THE ELECTRIC SPRITE
SUPPORT // CASH APP $UNIXARCADE
```

LiveJournal:
https://luminosity.livejournal.com

Forge AI OS by Luminosity:
https://luminosity.gumroad.com/l/fyosxi

Gumroad:
https://luminosity.gumroad.com

GitHub:
https://github.com/unixarcade

Goodreads // books written:
https://www.goodreads.com/review/list/1550470-matthew-kowalski?ref=nav_mybooks&shelf=books-i-have-written

---

# 0x14 // FINAL FORM

```text
              DREAM>
                 │
        ┌────────┴────────┐
        │                 │
      SIMPLE            DEEP
        │                 │
     few words        raw machine
        │                 │
        └────────┬────────┘
                 │
              YOUR CODE
```

**Dream is a typing environment with an escape hatch through the floor.**

Not everything needs another framework.
Sometimes you just need:

```text
Dream> _
```

…and a machine willing to listen.

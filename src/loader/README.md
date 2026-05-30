MODULE 3 — Binary Loader + baka-protocol
-------------------------------------------------------------------
What it does:
  Fetches compiled baka binaries over the network,
  validates them, wires them into memory, and executes them.
  Like a dynamic linker and HTTP client fused together.

Why it must exist:
  You type baka://tsun.social. Something has to fetch that binary,
  verify it isn't garbage, allocate memory for it, and jump to
  its entry point. That's this module.
```C
The BakaHeader (from actual blog code):
  __attribute__((section(".baka_header")))
  BakaHeader header = {
      .magic_number = 0x62616B61,   // "baka" in ASCII - verify this
      .version      = 1,            // compatibility check
      .memory_mb    = 64,           // "give me this much arena"
      .name         = "tsun_feed",
  };
```
  Magic number purpose: To verify if this is a baka.

The shadow header:
  Dev writes header manually  ->  their stated intent
  Build system scans all real_spawn() calls in project  ->  ground truth
  At load time: if they conflict, runtime warns or picks higher value
  "You said 4 threads, I found 7 spawn calls" - compile time safety net

Loader steps:
  1. baka-protocol connects to baka:// URL
  2. Network thread streams binary (feeds Module 4 with INTR_NET)
  3. Read first N bytes as BakaHeader
  4. Verify magic_number == 0x62616B61
  5. Check version compatibility
  6. Ask Module 2 for sub-arena of memory_mb size
  7. Copy binary into that arena
  8. Resolve relocations  <- the hard part (function pointer fixups)
  9. Locate baka_main symbol
  10. Call baka_main(api)  <- baka is now alive

The hard part - relocations:
  When you compile a binary, function call addresses are relative
  to where the binary is loaded in RAM. Load it at a different
  address and all those pointers are wrong. You have to fix them.
  This is what system dynamic linkers (ld.so) do. Not trivial.

---

## Current status

The tsundere_runtime takes baka path and pass it to this loader module due to this being a prototype the loader module is very naive.

It identifies the symbols location and loads and execute it. Pretty basic stuff tbh.

The problems to still consider.

1. The loading of child-baka, this needs to happen on IO thread hence for child-baka. Actually a better plan - All baka loads over IO thread We check if there is a existing process zero and if not then the first baka to load becomes that.


2. When the baka is not a single binary but is instead supposed to be assembled after fetching smol-baka from BDN(Baka delivery Network), so this module responsibility should evolve to do dynamic linking and resolution.


3. Developer can specifically design child-baka, meaning that baka is aware of parent baka from design principle hence not totally independent from parent-baka. The child-baka can ask for functions, struct and behaviour that is available to parent-baka only. Hence we need a method for that. The delima arises that arena alloc is supposed to make each process sandboxed even the interrupts from child-baka in principle doesn't voilate that, as child baka wouldn't know why they are modifying a specific data. But if child-baka start accessing the parent-baka func it would be breach in that contract. Hence there would exist a export like behaviour just like how AppState is available to all child-baka, parent-baka can expose AppBehaviour APIs for child-baka to inherit, while linking what our tsundere can do is do a cursed brain surgery, copy all the exported functions and then instead of just link that copied piece of code to all the spaw, here child can probably attack other child and cause harme but since parent is safe, we don't care.

Now how that hard copy of binary will be done and such thing is a question future Aakarsh would answer. I completely and utterly belive in future Aakarsh, he is reliable unlike past Aakarsh who is a piece of shit fuck that guy always giving me problems mf.




let
  hosts = {
    arceus = {
      sekun = "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAINI269n68/pDDfMjkPaWeRUldzr1I/dWfUZl7sZPktwCAAAABHNzaDo= software@sekun.net";
    };

    lucario = {
      root = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHX+3tKb0OOld/w0In1Ckq5gWKJgfSLMTqAIzXUJtLzG root@lucario";
    };
  };

  mew = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOq98pf8ZVPTjaLWB7lEFnyqHmVD40KfnTFWZ05xKzC9 sekun@ichi";
in {
  /* "emojiedDBPassword.age".publicKeys = [ sekun mew ]; */
  /* "emojiedDBCACert.age".publicKeys = [ sekun mew ]; */
  /* "tailscaleKey.age".publicKeys = [ sekun mew ]; */
  "ts_key__hydra.age".publicKeys = with hosts; [ lucario.root ];
}

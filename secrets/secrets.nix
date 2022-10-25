let
  sekun = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCnYwiKU31DCJCG9mAFJ72AhBVb/jfMVJm9UODTsPvVmtdsApnEnYanUboH1mM+z0W0XCEUWSHlRzqkFoTj2fOejalsBwALjKP8Bx+18SUIn5uEoy9FI9sjs/6vHx8Xt32fUhNU3r/inttFemRhpwodWooK537FbXqypt3dOcDbHr8anNO5xvdB+oscbPjHRJnp9j9iVsag31mynnSQe0yyIYooNTe77+0ZsxbgBtrooukEpLyOpdhL4iP7oWsXdb4xFM2xDlhD4MEdjblnom5ZmKKPssSuBV0HYnlOGmqjvXUj0xn+BlvbQiiTcTK14/KgldB+T5gc4R22s6VodTV0I6rTvdosudOTT4hHQecx9U2xN4xki27ygkGRcTJmrghShvE+lzU4ad4lotcKWv9AUGJopKURf8jtoF6AgDVYaQ42NhpVMwf4VW0Md/wWDDWXYh0N/4kRsCZEbRclDksLOuq3TbHP++wsoLfk5YTM0tu/+EDR/Cqdr0uXgaVYAyM= sekun@ichi";
  mew = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOq98pf8ZVPTjaLWB7lEFnyqHmVD40KfnTFWZ05xKzC9 sekun@ichi";
in {
  "emojiedDBPassword.age".publicKeys = [ sekun mew ];
  "emojiedDBCACert.age".publicKeys = [ sekun mew ];
  "tailscaleKey.age".publicKeys = [ sekun mew ];
}

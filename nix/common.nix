{ fetchFromGitHub }: rec {

  pname = "mobilizon";
  version = "4.1.0";

  src = fetchFromGitHub {
    owner = "CoenHolten";
    repo = "mobilizon-animal-rebellion";
    rev = "cebd234f54eafd779e1c6694c6f87dff88316383";
    hash = "sha256-ZqaHVeGq5d/ENOn7y6O1H4vWgvvPljPLZWZjYrCdsWo=";
  };
}

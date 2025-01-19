# gh-authswap

`gh-authswap` is a GitHub CLI extension that allows you to switch authentication contexts and automatically update your `.gitconfig` with the correct user name and email.

## Features

- Switch between multiple GitHub authentication contexts.
- Automatically fetch and update your `.gitconfig` with the current user's name and email.
- Simplifies managing multiple GitHub profiles (e.g., work and personal).

## Installation

To install the `gh-authswap` extension, run this:

    ```sh
    gh extension install khaled-0/gh-authswap
    ```


## Usage

To switch authentication contexts and update your `.gitconfig`, use the following command:

```sh
gh authswap
```

To switch to a `work` context:

```sh
gh authswap work
```

Or to switch to a `personal` context:

```sh
gh authswap personal
```

## Notes

- If the email address is `null` despite having the `user:email` scope, it is likely because the you have set your email address to private. 
[Check this guide to solve the issue](https://stackoverflow.com/a/35387123/16867144)
![](https://i.sstatic.net/fN8dy.png)

## Contributing

Contributions are welcome! Please open an issue or submit a pull request with your changes.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

## Contact

For any questions or support, please open an issue on the repository.


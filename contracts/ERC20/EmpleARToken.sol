// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/// @title EmpleAR Token Contract
/// @notice This contract implements an ERC20 token with pausability and ownership features.
/// @dev The token also supports blacklisting of addresses and categorizing transfers under specific "rubros".

/// @title Contrato de token EmpleAR
/// @notice Este contrato implementa un token ERC20 con funciones de pausabilidad y propiedad.
/// @dev El token también admite la inclusión de direcciones en listas negras y la categorización de transferencias en "rubros" específicos.

contract EmpleARToken is ERC20Pausable, Ownable {
    // Blocked addresses
    // Direcciones bloqueadas
    mapping(address => bool) private _blacklist;

    // Categories enabled on the platform
    // Rubros habilitados en la plataforma
    mapping(string => bool) private _rubros;
    string[] private _rubroList;

    // Events - Eventos
    event Blacklisted(address indexed account);
    event Unblacklisted(address indexed account);
    event TransferWithRubro(
        address indexed from,
        address indexed to,
        uint256 amount,
        string rubro
    );
    event NewRubro(string rubro);

    //  Custom errors - Errores personalizados
    error AddressBlacklisted(address blacklistedAddress);
    error RubroNotExists(string rubro);
    error RubroAlreadyExists(string rubro);

    /// @notice Contract constructor

    /// @notice Constructor de contrato
    constructor()
        ERC20("EmpleAR", "EAR")
        Ownable(msg.sender)
    {
        _initializeRubros();
    }

    /// @notice Mint new tokens
    /// @dev Only the owner can mint new tokens
    /// @param to The address to receive the newly minted tokens
    /// @param amount The amount of tokens to be minted

    /// @notice Agregar nuevos tokens
    /// @dev Solo el propietario puede agregar nuevos tokens
    /// @param to La dirección para recibir los tokens recién agregados
    /// @param amount La cantidad de tokens que se agregaran
    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }

    /// @notice Pause all token transfers
    /// @dev Only the owner can pause the contract

    /// @notice Pausar todas las transferencias de tokens
    /// @dev Solo el propietario puede pausar el contrato
    function pause() public onlyOwner {
        _pause();
    }

    /// @notice Unpause token transfers
    /// @dev Only the owner can unpause the contract

    /// @notice Reanudar transferencias de tokens
    /// @dev Solo el propietario puede anular la pausa del contrato
    function unpause() public onlyOwner {
        _unpause();
    }

    /// @notice Transfer tokens to a recipient under a specific rubro
    /// @dev The sender and recipient must not be blacklisted, and the rubro must exist
    /// @param recipient The address to receive the tokens
    /// @param amount The amount of tokens to transfer
    /// @param rubro The rubro under which the transfer is categorized
    /// @return Returns true if the transfer was successful

    /// @notice Transferir tokens a un destinatario bajo un rubro específico
    /// @dev El remitente y el destinatario no deben estar en la lista negra y el rubro debe existir
    /// @param recipient La dirección para recibir los tokens
    /// @param amount La cantidad de tokens a transferir
    /// @param rubro El rubro bajo el cual se clasifica la transferencia
    /// @return Devuelve verdadero si la transferencia fue exitosa

    function transfer(
        address recipient,
        uint256 amount,
        string memory rubro
    )
        public
        notBlacklisted(_msgSender())
        notBlacklisted(recipient)
        validRubro(rubro)
        returns (bool)
    {
        _transfer(_msgSender(), recipient, amount);
        emit TransferWithRubro(_msgSender(), recipient, amount, rubro);
        return true;
    }

    /// @notice Blacklist an address, preventing it from transferring tokens
    /// @dev Only the owner can blacklist an address
    /// @param account The address to blacklist

    /// @notice Incluir una dirección en la lista negra, evitando que transfiera tokens
    /// @dev Solo el propietario puede incluir una dirección en la lista negra
    /// @param account La dirección que se incluirá en la lista negra
    function blacklist(address account) public onlyOwner {
        _blacklist[account] = true;
        emit Blacklisted(account);
    }

    /// @notice Remove an address from the blacklist
    /// @dev Only the owner can remove an address from the blacklist
    /// @param account The address to unblacklist

    /// @notice Eliminar una dirección de la lista negra
    /// @dev Solo el propietario puede eliminar una dirección de la lista negra
    /// @param account La dirección que se eliminará de la lista negra
    function unblacklist(address account) public onlyOwner {
        _blacklist[account] = false;
        emit Unblacklisted(account);
    }

    /// @notice Modifier to check if an address is blacklisted
    /// @dev Reverts with a custom error if the address is blacklisted
    /// @param account The address to check

    /// @notice Modificador para comprobar si una dirección está en la lista negra
    /// @dev Revierte con un error personalizado si la dirección está en la lista negra
    /// @param account La dirección a comprobar
    modifier notBlacklisted(address account) {
        if (_blacklist[account]) {
            revert AddressBlacklisted(account);
        }
        _;
    }

    /// @notice Add a new rubro to the platform
    /// @dev Only the owner can add new rubros. Reverts if the rubro already exists.
    /// @param rubro The name of the rubro to add

    /// @notice Agregar un nuevo rubro a la plataforma
    /// @dev Solo el propietario puede agregar nuevos rubros. Revierte si el rubro ya existe.
    /// @param rubro El nombre del rubro a agregar
    function addRubro(string memory rubro) public onlyOwner {
        if (rubroExists(rubro)) {
            revert RubroAlreadyExists(rubro);
        }
        _rubros[rubro] = true;
        _rubroList.push(rubro);
        emit NewRubro(rubro);
    }

    /// @notice Get the list of all rubros on the platform
    /// @return Returns an array of all rubros

    /// @notice Obtiene la lista de todos los rubros en la plataforma
    /// @return Devuelve una matriz de todos los rubros
    function getRubros() public view returns (string[] memory) {
        return _rubroList;
    }

    /// @notice Check if a rubro exists
    /// @param rubro The name of the rubro to check
    /// @return Returns true if the rubro exists, false otherwise

    /// @notice Verifica si existe un rubro
    /// @param rubro El nombre del rubro a verificar
    /// @return Devuelve verdadero si el rubro existe, falso en caso contrario
    function rubroExists(string memory rubro) public view returns (bool) {
        return _rubros[rubro];
    }

    /// @notice Modifier to check if a rubro exists
    /// @dev Reverts with a custom error if the rubro does not exist
    /// @param rubro The name of the rubro to check

    /// @notice Modificador para comprobar si existe un rubro
    /// @dev Revierte con un error personalizado si el rubro no existe
    /// @param rubro El nombre del rubro a comprobar
    modifier validRubro(string memory rubro) {
        if (!_rubros[rubro]) {
            revert RubroNotExists(rubro);
        }
        _;
    }

    /// @notice Initialize default rubros in the platform
    /// @dev This function is called in the constructor to set up initial rubros

    /// @notice Inicializa rubros por defecto en la plataforma
    /// @dev Esta función se llama en el constructor para configurar rubros iniciales
    function _initializeRubros() internal {
        addRubro("plomeria");
        addRubro("pintor");
        addRubro("electricista");
    }
}

#include "dog.hh"

Dog::Dog (std::string name)
    :
    Animal(name)
{
    m_sound = "Woof!";
}

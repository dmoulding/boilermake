#include "cat.hh"

Cat::Cat (std::string name)
    :
    Animal(name)
{
    m_sound = "Meow!";
}

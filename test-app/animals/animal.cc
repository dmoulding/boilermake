#include <iostream>

#include "animal.hh"

Animal::Animal (std::string name)
{
    if (name.empty()) {
        name = "unknown";
    }
    else {
        m_name = name;
    }
}

void Animal::talk () const
{
    using namespace std;

    cout << m_name << " says, \"" << m_sound << "\"" << endl;
}
